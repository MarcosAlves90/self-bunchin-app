import 'package:bunchin_flutter/contracts/contract_parsing.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/location.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_clock.freezed.dart';

@freezed
abstract class CreatePunchRequest with _$CreatePunchRequest {
  const CreatePunchRequest._();

  const factory CreatePunchRequest({
    required PunchType type,
    PunchLocationSnapshot? location,
  }) = _CreatePunchRequest;

  JsonMap toApiJson() {
    return {
      'type': punchTypeToApi(type),
      if (location != null) 'location': location!.toApiJson(),
    };
  }
}

@freezed
abstract class TimeClockEmployeeSummary with _$TimeClockEmployeeSummary {
  const TimeClockEmployeeSummary._();

  const factory TimeClockEmployeeSummary({
    required String id,
    required String name,
    required String unit,
    required EmployeeStatus status,
    required EmployeeWorkMode workMode,
    required bool requiresLocationOnPunch,
    required bool trustedDeviceRequired,
  }) = _TimeClockEmployeeSummary;

  factory TimeClockEmployeeSummary.fromJson(JsonMap json) {
    return TimeClockEmployeeSummary(
      id: requireString(json, 'id'),
      name: requireString(json, 'name'),
      unit: requireString(json, 'unit'),
      status: employeeStatusFromApi(requireString(json, 'status')),
      workMode: employeeWorkModeFromApi(requireString(json, 'workMode')),
      requiresLocationOnPunch: requireBool(json, 'requiresLocationOnPunch'),
      trustedDeviceRequired: requireBool(json, 'trustedDeviceRequired'),
    );
  }
}

@freezed
abstract class TimeClockState with _$TimeClockState {
  const TimeClockState._();

  const factory TimeClockState({
    required TimeClockEmployeeSummary employee,
    required ShiftStatus currentStatus,
    required int todayWorkedMinutes,
    required int todayBreakMinutes,
    required DateTime? firstCheckInAt,
    required DateTime? lastPunchAt,
    required List<PunchRecord> records,
  }) = _TimeClockState;

  factory TimeClockState.fromJson(JsonMap json) {
    final rawRecords = requireJsonList(json['records'], 'records');

    return TimeClockState(
      employee: TimeClockEmployeeSummary.fromJson(
        requireJsonMap(json['employee'], 'employee'),
      ),
      currentStatus: shiftStatusFromApi(requireString(json, 'currentStatus')),
      todayWorkedMinutes: requireInt(json, 'todayWorkedMinutes'),
      todayBreakMinutes: requireInt(json, 'todayBreakMinutes'),
      firstCheckInAt: optionalDateTime(json, 'firstCheckInAt'),
      lastPunchAt: optionalDateTime(json, 'lastPunchAt'),
      records: rawRecords
          .map(
            (item) => PunchRecord.fromJson(
              requireJsonMap(item, 'records[]'),
            ),
          )
          .toList(),
    );
  }
}
