import 'dart:async';

import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/location.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/time_tracking/application/punch_location_service.dart';
import 'package:bunchin_flutter/features/time_tracking/presentation/time_clock_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBunchinApi extends BunchinApi {
  _FakeBunchinApi(this.state);

  final TimeClockState state;
  int getStateCalls = 0;
  CreatePunchRequest? lastPunchRequest;

  @override
  Future<TimeClockState> getMyTimeClockState() async {
    getStateCalls += 1;
    return state;
  }

  @override
  Future<PunchRecord> createPunch({
    required CreatePunchRequest request,
  }) async {
    lastPunchRequest = request;
    return PunchRecord(
      type: request.type,
      timestamp: DateTime.parse('2026-05-24T13:30:00Z'),
      detail: 'registrado',
      location: request.location,
    );
  }
}

class _BlockingPunchLocationService extends PunchLocationService {
  _BlockingPunchLocationService(this.permission);

  final Completer<PunchLocationResult> permission;

  @override
  Future<PunchLocationResult> requestPermission() => permission.future;
}

TimeClockState _timeClockState() {
  return TimeClockState(
    employee: const TimeClockEmployeeSummary(
      id: 'emp-01',
      name: 'Marina Silva',
      unit: 'Operações',
      status: EmployeeStatus.active,
      workMode: EmployeeWorkMode.onsite,
      requiresLocationOnPunch: true,
      trustedDeviceRequired: false,
    ),
    currentStatus: ShiftStatus.working,
    todayWorkedMinutes: 360,
    todayBreakMinutes: 30,
    firstCheckInAt: DateTime.parse('2026-05-24T08:00:00Z'),
    lastPunchAt: DateTime.parse('2026-05-24T12:00:00Z'),
    records: const <PunchRecord>[],
  );
}

void main() {
  test('start loads time clock state without waiting for location permission',
      () async {
    final permission = Completer<PunchLocationResult>();
    final api = _FakeBunchinApi(_timeClockState());
    final controller = TimeClockController(
      api: api,
      punchLocationService: _BlockingPunchLocationService(permission),
    );

    await controller.start();

    expect(api.getStateCalls, 1);
    expect(controller.isLoadingState, isFalse);
    expect(controller.employeeName, 'Marina Silva');
    expect(controller.status, ShiftStatus.working);
    expect(controller.locationState.status, PunchLocationStatus.checking);

    permission.complete(const PunchLocationResult.ready());
    await Future<void>.delayed(Duration.zero);

    expect(controller.locationState.status, PunchLocationStatus.ready);

    controller.dispose();
  });

  test(
    'handlePunch still registers punch when location capture has no snapshot',
    () async {
      final permission = Completer<PunchLocationResult>();
      final api = _FakeBunchinApi(_timeClockState());
      final controller = TimeClockController(
        api: api,
        punchLocationService: _BlockingPunchLocationService(permission),
      );

      permission.complete(const PunchLocationResult.ready());

      final message = await controller.handlePunch(PunchType.checkIn);

      expect(message, 'Entrada registrado sem localização.');
      expect(api.lastPunchRequest, isNotNull);
      expect(api.lastPunchRequest?.location, isNull);
      expect(controller.isSubmittingPunch, isFalse);

      controller.dispose();
    },
  );
}
