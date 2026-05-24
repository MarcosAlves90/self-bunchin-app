import 'package:bunchin_flutter/contracts/location.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/time_tracking/application/punch_location_service.dart';
import 'package:bunchin_flutter/features/time_tracking/presentation/time_clock_controller.dart';
import 'package:bunchin_flutter/features/time_tracking/presentation/time_clock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTimeClockController extends TimeClockController {
  _FakeTimeClockController()
      : super(
          api: _FakeTimeClockApi(),
          punchLocationService: _FakePunchLocationService(),
        );

  PunchType? lastPunchType;

  @override
  Future<void> start() async {}

  @override
  Future<String?> handlePunch(PunchType type) async {
    lastPunchType = type;
    return 'Entrada registrado com sucesso.';
  }
}

class _FakeTimeClockApi extends BunchinApi {}

class _FakePunchLocationService extends PunchLocationService {
  const _FakePunchLocationService();
}

void main() {
  testWidgets('tap on register entry calls punch handler',
      (WidgetTester tester) async {
    final controller = _FakeTimeClockController()
      ..isLoadingState = false
      ..employeeName = 'Marina Silva'
      ..employeeUnit = 'Operações'
      ..status = ShiftStatus.checkedOut
      ..todayWorkedMinutes = 0
      ..todayBreakMinutes = 0
      ..records = const <PunchRecord>[];

    await tester.binding.setSurfaceSize(const Size(1400, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: TimeClockPage(controller: controller),
      ),
    );

    await tester.pump();

    await tester.ensureVisible(find.text('Registrar entrada'));
    await tester.tap(find.text('Registrar entrada'));
    await tester.pump();

    expect(controller.lastPunchType, PunchType.checkIn);
  });
}
