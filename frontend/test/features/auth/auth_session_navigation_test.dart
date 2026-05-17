import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:bunchin_flutter/features/auth/presentation/auth_session_navigation.dart';
import 'package:bunchin_flutter/features/time_tracking/presentation/time_clock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('routes super admin to admin workspace even without employee profile',
      (WidgetTester tester) async {
    final session = AuthSession(
      accessToken: 'token-123',
      tokenType: 'bearer',
      expiresAt: DateTime.parse('2026-04-26T18:00:00Z'),
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
        email: 'super.admin@bunchin.com',
        role: 'super_admin',
      ),
    );

    final route = buildAuthenticatedWorkspaceRoute(session) as MaterialPageRoute<void>;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: route.builder)));
    await tester.pump();

    expect(find.byType(AdminEmployeesPage), findsOneWidget);
    expect(find.byType(TimeClockPage), findsNothing);
  });

  testWidgets('routes manager to time clock workspace',
      (WidgetTester tester) async {
    final session = AuthSession(
      accessToken: 'token-123',
      tokenType: 'bearer',
      expiresAt: DateTime.parse('2026-04-26T18:00:00Z'),
      company: const AuthCompanySummary(
        id: 'cmp-01',
        legalName: 'Bunchin Tecnologia LTDA',
        tradeName: 'Bunchin',
        cnpjMasked: '12.***.***/****-90',
        emailMasked: 'co*****@bunchin.com',
        phoneMasked: '11*****0000',
      ),
      user: const AuthUserSummary(
        id: 'usr-02',
        email: 'manager@bunchin.com',
        role: 'manager',
        employeeId: 'emp-02',
      ),
    );

    final route = buildAuthenticatedWorkspaceRoute(session) as MaterialPageRoute<void>;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: route.builder)));
    await tester.pump();

    expect(find.byType(TimeClockPage), findsOneWidget);
    expect(find.byType(AdminEmployeesPage), findsNothing);
  });
}
