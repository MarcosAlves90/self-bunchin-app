import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dump', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: AdminEmployeesPage(api: _FakeAdminApi())),
    );
    await tester.pumpAndSettle();
    debugDumpRenderTree();
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

  @override
  Future<ManagedPunchPage> listManagedPunches(
    String employeeId, {
    int page = 1,
    int limit = 4,
  }) async {
    return ManagedPunchPage(
      records: const <ManagedPunchRecord>[],
      recordsPage: page,
      recordsPageSize: limit,
      recordsTotal: 0,
      recordsTotalPages: 1,
      recordsHasPrevious: false,
      recordsHasNext: false,
    );
  }
}
