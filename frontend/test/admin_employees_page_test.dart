import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders admin employee dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminEmployeesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Administrar equipe'), findsOneWidget);
    expect(find.text('Novo funcionario'), findsOneWidget);
    expect(find.text('Marina Costa'), findsNWidgets(2));
    expect(find.text('Funcionarios da empresa'), findsOneWidget);
  });
}
