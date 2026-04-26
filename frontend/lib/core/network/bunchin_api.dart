import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/location.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/storage/token_storage.dart';

class LoginResult {
  const LoginResult({required this.accessToken});

  final String accessToken;
}

class TimeClockStateData {
  const TimeClockStateData({
    required this.employeeName,
    required this.employeeUnit,
    required this.currentStatus,
    required this.todayWorkedMinutes,
    required this.todayBreakMinutes,
    required this.records,
  });

  final String employeeName;
  final String employeeUnit;
  final ShiftStatus currentStatus;
  final int todayWorkedMinutes;
  final int todayBreakMinutes;
  final List<PunchRecord> records;
}

class BunchinApi {
  BunchinApi({ApiClient? client, TokenStorage? tokenStorage})
    : _client = client ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<LoginResult> login({
    required String email,
    required String password,
    required bool keepConnected,
  }) async {
    final response = await _client.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'keepConnected': keepConnected,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException('Resposta invalida de autenticacao.');
    }

    final token = response['accessToken'];
    if (token is! String || token.isEmpty) {
      throw ApiException('Token de acesso ausente na resposta de login.');
    }

    await _tokenStorage.saveAccessToken(token);
    return LoginResult(accessToken: token);
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', withAuth: true);
    } finally {
      await _tokenStorage.clearAccessToken();
    }
  }

  Future<List<EmployeeProfile>> listEmployees() async {
    final response = await _client.get('/employees', withAuth: true);
    if (response is! List) {
      throw ApiException('Resposta invalida ao listar funcionarios.');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(_employeeFromJson)
        .toList();
  }

  Future<EmployeeProfile> createEmployee(EmployeeDraft draft) async {
    final response = await _client.post(
      '/employees',
      withAuth: true,
      body: _employeeDraftToJson(draft),
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException('Resposta invalida ao criar funcionario.');
    }

    return _employeeFromJson(response);
  }

  Future<EmployeeProfile> updateEmployee(
    String employeeId,
    EmployeeDraft draft,
  ) async {
    final response = await _client.put(
      '/employees/$employeeId',
      withAuth: true,
      body: _employeeDraftToJson(draft),
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException('Resposta invalida ao atualizar funcionario.');
    }

    return _employeeFromJson(response);
  }

  Future<TimeClockStateData> getMyTimeClockState() async {
    final response = await _client.get('/time-clock/me', withAuth: true);
    if (response is! Map<String, dynamic>) {
      throw ApiException('Resposta invalida ao carregar estado do ponto.');
    }

    final employee = response['employee'];
    final status = response['currentStatus'];
    final recordsRaw = response['records'];

    if (employee is! Map<String, dynamic> ||
        status is! String ||
        recordsRaw is! List) {
      throw ApiException('Dados de ponto incompletos na resposta.');
    }

    final records = recordsRaw
        .whereType<Map<String, dynamic>>()
        .map(_punchRecordFromJson)
        .toList();

    return TimeClockStateData(
      employeeName: employee['name'] as String? ?? 'Funcionario',
      employeeUnit: employee['unit'] as String? ?? '-',
      currentStatus: _shiftStatusFromApi(status),
      todayWorkedMinutes: (response['todayWorkedMinutes'] as num?)?.toInt() ?? 0,
      todayBreakMinutes: (response['todayBreakMinutes'] as num?)?.toInt() ?? 0,
      records: records,
    );
  }

  Future<PunchRecord> createPunch({
    required PunchType type,
    required PunchLocationSnapshot location,
  }) async {
    final response = await _client.post(
      '/time-clock/me/punches',
      withAuth: true,
      body: {
        'type': _punchTypeToApi(type),
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracyMeters': location.accuracyMeters,
          'capturedAt': location.capturedAt.toUtc().toIso8601String(),
        },
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException('Resposta invalida ao registrar batida.');
    }

    return _punchRecordFromJson(response);
  }

  EmployeeProfile _employeeFromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      department: json['department'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      expectedShift: json['expectedShift'] as String? ?? '',
      status: _employeeStatusFromApi(json['status'] as String? ?? 'inactive'),
      workMode: _employeeWorkModeFromApi(json['workMode'] as String? ?? 'onsite'),
      roleLevel: _roleLevelFromApi(json['roleLevel'] as String? ?? 'staff'),
      requiresLocationOnPunch: json['requiresLocationOnPunch'] as bool? ?? false,
      trustedDeviceRequired: json['trustedDeviceRequired'] as bool? ?? false,
      todayWorkedMinutes: (json['todayWorkedMinutes'] as num?)?.toInt() ?? 0,
      pendingAdjustments: (json['pendingAdjustments'] as num?)?.toInt() ?? 0,
      lastPunchAt: _parseDateTime(json['lastPunchAt'] as String?),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> _employeeDraftToJson(EmployeeDraft draft) {
    return {
      'name': draft.name,
      'role': draft.role,
      'department': draft.department,
      'email': draft.email,
      'phone': draft.phone,
      'unit': draft.unit,
      'expectedShift': draft.expectedShift,
      'status': _employeeStatusToApi(draft.status),
      'workMode': _employeeWorkModeToApi(draft.workMode),
      'roleLevel': _roleLevelToApi(draft.roleLevel),
      'requiresLocationOnPunch': draft.requiresLocationOnPunch,
      'trustedDeviceRequired': draft.trustedDeviceRequired,
      'notes': draft.notes,
    };
  }

  PunchRecord _punchRecordFromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];
    return PunchRecord(
      type: _punchTypeFromApi(json['type'] as String? ?? 'checkIn'),
      timestamp: _parseDateTime(json['timestamp'] as String?) ?? DateTime.now(),
      detail: json['detail'] as String? ?? '',
      location: locationJson is Map<String, dynamic>
          ? PunchLocationSnapshot(
              latitude: (locationJson['latitude'] as num?)?.toDouble() ?? 0,
              longitude: (locationJson['longitude'] as num?)?.toDouble() ?? 0,
              accuracyMeters:
                  (locationJson['accuracyMeters'] as num?)?.toDouble() ?? 0,
              capturedAt:
                  _parseDateTime(locationJson['capturedAt'] as String?) ??
                  DateTime.now(),
            )
          : null,
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }

  EmployeeStatus _employeeStatusFromApi(String value) {
    return switch (value) {
      'active' => EmployeeStatus.active,
      'onboarding' => EmployeeStatus.onboarding,
      'onLeave' => EmployeeStatus.onLeave,
      _ => EmployeeStatus.inactive,
    };
  }

  String _employeeStatusToApi(EmployeeStatus value) {
    return switch (value) {
      EmployeeStatus.active => 'active',
      EmployeeStatus.onboarding => 'onboarding',
      EmployeeStatus.onLeave => 'onLeave',
      EmployeeStatus.inactive => 'inactive',
    };
  }

  EmployeeWorkMode _employeeWorkModeFromApi(String value) {
    return switch (value) {
      'onsite' => EmployeeWorkMode.onsite,
      'hybrid' => EmployeeWorkMode.hybrid,
      _ => EmployeeWorkMode.remote,
    };
  }

  String _employeeWorkModeToApi(EmployeeWorkMode value) {
    return switch (value) {
      EmployeeWorkMode.onsite => 'onsite',
      EmployeeWorkMode.hybrid => 'hybrid',
      EmployeeWorkMode.remote => 'remote',
    };
  }

  RoleLevel _roleLevelFromApi(String value) {
    return switch (value) {
      'leadership' => RoleLevel.leadership,
      'specialist' => RoleLevel.specialist,
      _ => RoleLevel.staff,
    };
  }

  String _roleLevelToApi(RoleLevel value) {
    return switch (value) {
      RoleLevel.staff => 'staff',
      RoleLevel.specialist => 'specialist',
      RoleLevel.leadership => 'leadership',
    };
  }

  ShiftStatus _shiftStatusFromApi(String value) {
    return switch (value) {
      'working' => ShiftStatus.working,
      'onBreak' => ShiftStatus.onBreak,
      _ => ShiftStatus.checkedOut,
    };
  }

  PunchType _punchTypeFromApi(String value) {
    return switch (value) {
      'checkIn' => PunchType.checkIn,
      'breakStart' => PunchType.breakStart,
      'breakEnd' => PunchType.breakEnd,
      _ => PunchType.checkOut,
    };
  }

  String _punchTypeToApi(PunchType value) {
    return switch (value) {
      PunchType.checkIn => 'checkIn',
      PunchType.breakStart => 'breakStart',
      PunchType.breakEnd => 'breakEnd',
      PunchType.checkOut => 'checkOut',
    };
  }
}
