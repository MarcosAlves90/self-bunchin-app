import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_controller.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows local loading state without hiding workspace shell',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: AdminEmployeesPage(controller: _LoadingAdminController()),
      ),
    );
    await tester.pump();

    expect(find.text('Administrar equipe'), findsOneWidget);
    expect(find.text('Carregando funcionários'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('renders desktop admin header with create action on the right',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: AdminEmployeesPage(api: _FakeAdminApi())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Administrar equipe'), findsOneWidget);
    expect(find.text('Novo funcionário'), findsOneWidget);
    expect(find.text('Editar selecionado'), findsNothing);
    expect(find.byIcon(Icons.more_horiz_rounded), findsWidgets);
    expect(find.text('renata.souza@bunchin.com'), findsOneWidget);
    expect(find.text('Sem batida recente'), findsNothing);
    expect(find.textContaining('Hoje:'), findsNothing);
    expect(find.text('Ativo'), findsOneWidget);
    expect(find.text('Resumo rápido'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);
    expect(find.text('Políticas'), findsOneWidget);
    expect(find.text('Notas'), findsOneWidget);

    final punchTab = find.text('Ponto').last;
    await tester.ensureVisible(punchTab);
    await tester.tap(punchTab);
    await tester.pumpAndSettle();

    expect(find.text('Gestão de ponto'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    expect(find.text('Novo funcionário'), findsOneWidget);
  });

  testWidgets('does not render selected edit action in mobile header',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: AdminEmployeesPage(api: _FakeAdminApi())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Novo funcionário'), findsOneWidget);
    expect(find.text('Editar selecionado'), findsNothing);
    expect(find.byIcon(Icons.badge_rounded), findsNothing);
  });

  testWidgets('renders company data from auth context in the sidebar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: AdminEmployeesPage(api: _FakeAdminApi())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bunchin'), findsOneWidget);
    expect(find.text('Bunchin Tecnologia LTDA'), findsOneWidget);
    expect(find.textContaining('CNPJ'), findsNothing);
    expect(find.text('Contato'), findsNothing);
    expect(find.text('co*****@bunchin.com'), findsNothing);
    expect(find.text('Tel. 11*****0000'), findsNothing);
    expect(find.text('Perfil administrador'), findsOneWidget);
    expect(find.text('Dados mascarados'), findsOneWidget);
  });

  testWidgets('opens punch tab without runtime error and shows empty state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: AdminEmployeesPage(api: _FakeAdminApi())),
    );
    await tester.pumpAndSettle();

    final punchTab = find.text('Ponto').last;
    await tester.ensureVisible(punchTab);
    await tester.tap(punchTab);
    await tester.pumpAndSettle();

    expect(find.text('Novo ponto'), findsWidgets);
    expect(find.byIcon(Icons.refresh_rounded), findsWidgets);
    expect(find.text('Nenhum ponto manual registrado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paginates managed punches on the admin screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: AdminEmployeesPage(
          api: _FakeAdminApi(
            managedPunchesByEmployeeId: <String, List<ManagedPunchRecord>>{
              'emp-99': List<ManagedPunchRecord>.generate(5, (index) {
                final day = index + 1;
                return ManagedPunchRecord(
                  id: 'punch-$day',
                  employeeId: 'emp-99',
                  type: PunchType.checkIn,
                  timestamp: DateTime(2026, 5, day, 8, 0),
                  detail: 'Ponto $day',
                  projectId: null,
                  location: null,
                );
              }),
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final punchTab = find.text('Ponto').last;
    await tester.ensureVisible(punchTab);
    await tester.tap(punchTab);
    await tester.pumpAndSettle();

    expect(find.text('Página 1 de 2'), findsOneWidget);
    expect(find.text('Ponto 5'), findsOneWidget);
    expect(find.text('Ponto 2'), findsOneWidget);
    expect(find.text('Ponto 1'), findsNothing);

    final nextPage = find.text('Próxima');
    await tester.ensureVisible(nextPage);
    await tester.tap(nextPage);
    await tester.pumpAndSettle();

    expect(find.text('Página 2 de 2'), findsOneWidget);
    expect(find.text('Ponto 1'), findsOneWidget);
    expect(find.text('Ponto 5'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _FakeAdminApi extends BunchinApi {
  _FakeAdminApi(
      {Map<String, List<ManagedPunchRecord>>? managedPunchesByEmployeeId})
      : managedPunchesByEmployeeId =
            managedPunchesByEmployeeId ?? <String, List<ManagedPunchRecord>>{};

  final Map<String, List<ManagedPunchRecord>> managedPunchesByEmployeeId;

  @override
  Future<AuthContext> getAuthContext() async {
    return AuthContext(
      company: const AuthCompanySummary(
        id: 'cmp-01',
        legalName: 'Bunchin Tecnologia LTDA',
        tradeName: 'Bunchin',
        cnpjMasked: '12.***.***/****-90',
        emailMasked: 'co*****@bunchin.com',
        phoneMasked: '11*****0000',
      ),
      user: const AuthUserSummary(
        id: 'usr-01',
        email: 'admin@bunchin.com',
        role: 'admin',
        employeeId: null,
      ),
    );
  }

  @override
  Future<List<EmployeeProfile>> listEmployees() async {
    return <EmployeeProfile>[
      EmployeeProfile(
        id: 'emp-99',
        name: 'Renata Souza',
        role: 'Analista Financeira',
        department: 'Financeiro',
        email: 'renata.souza@bunchin.com',
        phone: '(11) 94444-6060',
        unit: 'Backoffice Centro',
        expectedShiftStart: const TimeOfDay(hour: 8, minute: 0),
        expectedShiftEnd: const TimeOfDay(hour: 17, minute: 0),
        status: EmployeeStatus.active,
        workMode: EmployeeWorkMode.hybrid,
        roleLevel: RoleLevel.specialist,
        requiresLocationOnPunch: false,
        trustedDeviceRequired: true,
        todayWorkedMinutes: 0,
        pendingAdjustments: 0,
        lastPunchAt: null,
        notes: 'Nova contratacao.',
      ),
    ];
  }

  @override
  Future<ManagedPunchPage> listManagedPunches(
    String employeeId, {
    int page = 1,
    int limit = 4,
  }) async {
    final records = <ManagedPunchRecord>[
      ...managedPunchesByEmployeeId[employeeId] ?? <ManagedPunchRecord>[],
    ]..sort((left, right) {
        final timestampComparison = right.timestamp.compareTo(left.timestamp);
        if (timestampComparison != 0) {
          return timestampComparison;
        }
        return right.id.compareTo(left.id);
      });
    final totalPages = records.isEmpty ? 1 : (records.length / limit).ceil();
    final normalizedPage = page.clamp(1, totalPages);
    final startIndex = (normalizedPage - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, records.length);
    return ManagedPunchPage(
      records: records.sublist(startIndex, endIndex),
      recordsPage: normalizedPage,
      recordsPageSize: limit,
      recordsTotal: records.length,
      recordsTotalPages: totalPages,
      recordsHasPrevious: normalizedPage > 1,
      recordsHasNext: normalizedPage < totalPages,
    );
  }

  @override
  Future<ManagedPunchRecord> createManagedPunch({
    required String employeeId,
    required ManagedPunchDraft draft,
  }) async {
    return ManagedPunchRecord(
      id: 'punch-01',
      employeeId: employeeId,
      type: draft.type,
      timestamp: draft.timestamp,
      detail: draft.detail,
      projectId: draft.projectId,
      location: draft.location,
    );
  }

  @override
  Future<ManagedPunchRecord> updateManagedPunch({
    required String employeeId,
    required String punchId,
    required ManagedPunchDraft draft,
  }) async {
    return ManagedPunchRecord(
      id: punchId,
      employeeId: employeeId,
      type: draft.type,
      timestamp: draft.timestamp,
      detail: draft.detail,
      projectId: draft.projectId,
      location: draft.location,
    );
  }

  @override
  Future<void> deleteManagedPunch({
    required String employeeId,
    required String punchId,
  }) async {}
}

class _LoadingAdminController extends AdminEmployeesController {
  _LoadingAdminController() : super(api: _FakeAdminApi());

  @override
  Future<void> start() async {}
}
