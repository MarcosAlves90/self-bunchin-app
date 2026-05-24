import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/contract_parsing.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/storage/token_storage.dart';

class BunchinApi {
  BunchinApi({ApiClient? client, TokenStorage? tokenStorage})
      : _client = client ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<AuthSession> login({
    required LoginCredentials credentials,
  }) async {
    final response = await _client.post(
      '/auth/login',
      body: credentials.toApiJson(),
    );

    return _persistSession(
      _parseContract(
        'login',
        () => AuthSession.fromJson(requireJsonMap(response, 'login response')),
      ),
    );
  }

  Future<AuthSession> registerCompany({
    required CompanyRegistrationDraft draft,
  }) async {
    final response = await _client.post(
      '/auth/register-company',
      body: draft.toApiJson(),
    );

    return _persistSession(
      _parseContract(
        'register-company',
        () => AuthSession.fromJson(
          requireJsonMap(response, 'register-company response'),
        ),
      ),
    );
  }

  Future<AuthContext> getAuthContext() async {
    final response = await _client.get('/auth/me', withAuth: true);
    return _parseContract(
      'auth/me',
      () => AuthContext.fromJson(requireJsonMap(response, 'auth/me response')),
    );
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', withAuth: true);
    } finally {
      await _tokenStorage.clearAccessToken();
    }
  }

  Future<String> resetPassword({required String email}) async {
    final response = await _client.post(
      '/auth/reset-password',
      body: {'email': email},
    );

    final map = requireJsonMap(response, 'reset-password response');
    return requireString(map, 'message');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.post(
      '/auth/change-password',
      withAuth: true,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<List<EmployeeProfile>> listEmployees() async {
    final response = await _client.get('/employees', withAuth: true);
    return _parseContract('employees', () {
      final payload = requireJsonList(response, 'employees response');
      return payload
          .map(
            (item) => EmployeeProfile.fromJson(
              requireJsonMap(item, 'employees[]'),
            ),
          )
          .toList();
    });
  }

  Future<EmployeeProfile> createEmployee(EmployeeDraft draft) async {
    final response = await _client.post(
      '/employees',
      withAuth: true,
      body: draft.toApiJson(),
    );

    return _parseContract(
      'create employee',
      () => EmployeeProfile.fromJson(
        requireJsonMap(response, 'create employee response'),
      ),
    );
  }

  Future<EmployeeProfile> updateEmployee(
    String employeeId,
    EmployeeDraft draft,
  ) async {
    final response = await _client.put(
      '/employees/$employeeId',
      withAuth: true,
      body: draft.toApiJson(),
    );

    return _parseContract(
      'update employee',
      () => EmployeeProfile.fromJson(
        requireJsonMap(response, 'update employee response'),
      ),
    );
  }

  Future<void> deleteEmployee(String employeeId) async {
    await _client.delete('/employees/$employeeId', withAuth: true);
  }

  Future<List<ManagedPunchRecord>> listManagedPunches(String employeeId) async {
    final response = await _client.get(
      '/time-clock/employees/$employeeId/punches',
      withAuth: true,
    );

    return _parseContract('managed punches', () {
      final payload = requireJsonList(response, 'managed punches response');
      return payload
          .map(
            (item) => ManagedPunchRecord.fromJson(
              requireJsonMap(item, 'managed punches[]'),
            ),
          )
          .toList();
    });
  }

  Future<ManagedPunchRecord> createManagedPunch({
    required String employeeId,
    required ManagedPunchDraft draft,
  }) async {
    final response = await _client.post(
      '/time-clock/employees/$employeeId/punches',
      withAuth: true,
      body: draft.toCreateApiJson(),
    );

    return _parseContract(
      'create managed punch',
      () => ManagedPunchRecord.fromJson(
        requireJsonMap(response, 'create managed punch response'),
      ),
    );
  }

  Future<ManagedPunchRecord> updateManagedPunch({
    required String employeeId,
    required String punchId,
    required ManagedPunchDraft draft,
  }) async {
    final response = await _client.put(
      '/time-clock/employees/$employeeId/punches/$punchId',
      withAuth: true,
      body: draft.toUpdateApiJson(),
    );

    return _parseContract(
      'update managed punch',
      () => ManagedPunchRecord.fromJson(
        requireJsonMap(response, 'update managed punch response'),
      ),
    );
  }

  Future<void> deleteManagedPunch({
    required String employeeId,
    required String punchId,
  }) async {
    await _client.delete(
      '/time-clock/employees/$employeeId/punches/$punchId',
      withAuth: true,
    );
  }

  Future<TimeClockState> getMyTimeClockState() async {
    final response = await _client.get('/time-clock/me', withAuth: true);

    return _parseContract(
      'time-clock/me',
      () => TimeClockState.fromJson(
        requireJsonMap(response, 'time-clock/me response'),
      ),
    );
  }

  Future<PunchRecord> createPunch({
    required CreatePunchRequest request,
  }) async {
    final response = await _client.post(
      '/time-clock/me/punches',
      withAuth: true,
      body: request.toApiJson(),
    );

    return _parseContract(
      'create punch',
      () => PunchRecord.fromJson(
        requireJsonMap(response, 'create punch response'),
      ),
    );
  }

  Future<AuthSession> _persistSession(AuthSession session) async {
    await _tokenStorage.saveAccessToken(session.accessToken);
    return session;
  }

  T _parseContract<T>(String endpoint, T Function() parser) {
    try {
      return parser();
    } on ContractParsingException catch (error) {
      throw ApiException(
        'Contrato invalido na resposta de $endpoint: ${error.message}',
      );
    }
  }
}
