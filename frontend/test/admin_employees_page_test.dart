import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(find.text('Remover selecionado'), findsOneWidget);
    expect(find.text('Editar selecionado'), findsNothing);
    expect(find.byTooltip('Editar funcionário'), findsNothing);
    expect(find.text('renata.souza@bunchin.com'), findsOneWidget);
    expect(find.text('Sem batida recente'), findsNothing);
    expect(find.textContaining('Hoje:'), findsNothing);
    expect(find.text('Ativo'), findsOneWidget);
    expect(find.byIcon(Icons.badge_rounded), findsOneWidget);
    expect(find.text('Resumo rápido'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);
    expect(find.text('Políticas'), findsOneWidget);
    expect(find.text('Notas'), findsOneWidget);

    final createButtonFinder = find.widgetWithText(
      ElevatedButton,
      'Novo funcionário',
    );
    final createButtonRightEdge = tester.getTopRight(createButtonFinder).dx;

    expect(createButtonRightEdge, greaterThanOrEqualTo(1400));
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
    expect(find.text('Remover selecionado'), findsOneWidget);
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
}

class _FakeAdminApi extends BunchinApi {
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
}
