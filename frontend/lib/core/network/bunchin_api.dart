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
