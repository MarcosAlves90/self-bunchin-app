import 'package:flutter_test/flutter_test.dart';

import 'package:bunchin_flutter/main.dart';

void main() {
  testWidgets('renders login experience on startup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsNWidgets(2));
    expect(find.text('BUNCHIN'), findsWidgets);
    expect(find.text('Cadastrar empresa'), findsOneWidget);
  });
}
