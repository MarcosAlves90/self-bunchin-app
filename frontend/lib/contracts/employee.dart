import 'package:bunchin_flutter/contracts/contract_parsing.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';

enum EmployeeFilter { all, active, attention, inactive }

enum EmployeeStatus { active, onboarding, onLeave, inactive }

enum EmployeeWorkMode { onsite, hybrid, remote }

enum RoleLevel { staff, specialist, leadership }

EmployeeStatus employeeStatusFromApi(String value) {
  return switch (value) {
    'active' => EmployeeStatus.active,
    'onboarding' => EmployeeStatus.onboarding,
    'onLeave' => EmployeeStatus.onLeave,
    'inactive' => EmployeeStatus.inactive,
    _ => throw ContractParsingException(
        'Unsupported employee status value: $value',
      ),
  };
}

String employeeStatusToApi(EmployeeStatus value) {
  return switch (value) {
    EmployeeStatus.active => 'active',
    EmployeeStatus.onboarding => 'onboarding',
    EmployeeStatus.onLeave => 'onLeave',
    EmployeeStatus.inactive => 'inactive',
  };
}

EmployeeWorkMode employeeWorkModeFromApi(String value) {
  return switch (value) {
    'onsite' => EmployeeWorkMode.onsite,
    'hybrid' => EmployeeWorkMode.hybrid,
    'remote' => EmployeeWorkMode.remote,
    _ => throw ContractParsingException(
        'Unsupported employee work mode value: $value',
      ),
  };
}

String employeeWorkModeToApi(EmployeeWorkMode value) {
  return switch (value) {
    EmployeeWorkMode.onsite => 'onsite',
    EmployeeWorkMode.hybrid => 'hybrid',
    EmployeeWorkMode.remote => 'remote',
  };
}

RoleLevel roleLevelFromApi(String value) {
  return switch (value) {
    'staff' => RoleLevel.staff,
    'specialist' => RoleLevel.specialist,
    'leadership' => RoleLevel.leadership,
    _ => throw ContractParsingException(
        'Unsupported role level value: $value',
      ),
  };
}

String roleLevelToApi(RoleLevel value) {
  return switch (value) {
    RoleLevel.staff => 'staff',
    RoleLevel.specialist => 'specialist',
    RoleLevel.leadership => 'leadership',
  };
}

@freezed
abstract class EmployeeProfile with _$EmployeeProfile {
  const EmployeeProfile._();

  const factory EmployeeProfile({
    required String id,
    required String name,
    required String role,
    required String department,
    required String email,
    required String phone,
    required String unit,
    required String expectedShift,
    required EmployeeStatus status,
    required EmployeeWorkMode workMode,
    required RoleLevel roleLevel,
    required bool requiresLocationOnPunch,
    required bool trustedDeviceRequired,
    required int todayWorkedMinutes,
    required int pendingAdjustments,
    required DateTime? lastPunchAt,
    required String notes,
  }) = _EmployeeProfile;

  factory EmployeeProfile.fromJson(JsonMap json) {
    return EmployeeProfile(
      id: requireString(json, 'id'),
      name: requireString(json, 'name'),
      role: requireString(json, 'role'),
      department: requireString(json, 'department'),
      email: requireString(json, 'email'),
      phone: requireString(json, 'phone'),
      unit: requireString(json, 'unit'),
      expectedShift: requireString(json, 'expectedShift'),
      status: employeeStatusFromApi(requireString(json, 'status')),
      workMode: employeeWorkModeFromApi(requireString(json, 'workMode')),
      roleLevel: roleLevelFromApi(requireString(json, 'roleLevel')),
      requiresLocationOnPunch: requireBool(json, 'requiresLocationOnPunch'),
      trustedDeviceRequired: requireBool(json, 'trustedDeviceRequired'),
      todayWorkedMinutes: requireInt(json, 'todayWorkedMinutes'),
      pendingAdjustments: requireInt(json, 'pendingAdjustments'),
      lastPunchAt: optionalDateTime(json, 'lastPunchAt'),
      notes: requireString(json, 'notes'),
    );
  }

  factory EmployeeProfile.fromDraft({
    required String id,
    required EmployeeDraft draft,
  }) {
    return EmployeeProfile(
      id: id,
      name: draft.name,
      role: draft.role,
      department: draft.department,
      email: draft.email,
      phone: draft.phone,
      unit: draft.unit,
      expectedShift: draft.expectedShift,
      status: draft.status,
      workMode: draft.workMode,
      roleLevel: draft.roleLevel,
      requiresLocationOnPunch: draft.requiresLocationOnPunch,
      trustedDeviceRequired: draft.trustedDeviceRequired,
      todayWorkedMinutes: 0,
      pendingAdjustments: draft.status == EmployeeStatus.onboarding ? 2 : 0,
      lastPunchAt: null,
      notes: draft.notes,
    );
  }

  EmployeeProfile applyDraft(EmployeeDraft draft) {
    return EmployeeProfile(
      id: id,
      name: draft.name,
      role: draft.role,
      department: draft.department,
      email: draft.email,
      phone: draft.phone,
      unit: draft.unit,
      expectedShift: draft.expectedShift,
      status: draft.status,
      workMode: draft.workMode,
      roleLevel: draft.roleLevel,
      requiresLocationOnPunch: draft.requiresLocationOnPunch,
      trustedDeviceRequired: draft.trustedDeviceRequired,
      todayWorkedMinutes: todayWorkedMinutes,
      pendingAdjustments: pendingAdjustments,
      lastPunchAt: lastPunchAt,
      notes: draft.notes,
    );
  }
}

@freezed
abstract class EmployeeDraft with _$EmployeeDraft {
  const EmployeeDraft._();

  const factory EmployeeDraft({
    required String name,
    required String role,
    required String department,
    required String email,
    required String phone,
    required String unit,
    required String expectedShift,
    required EmployeeStatus status,
    required EmployeeWorkMode workMode,
    required RoleLevel roleLevel,
    required bool requiresLocationOnPunch,
    required bool trustedDeviceRequired,
    required String notes,
  }) = _EmployeeDraft;

  factory EmployeeDraft.fromEmployee(EmployeeProfile employee) {
    return EmployeeDraft(
      name: employee.name,
      role: employee.role,
      department: employee.department,
      email: employee.email,
      phone: employee.phone,
      unit: employee.unit,
      expectedShift: employee.expectedShift,
      status: employee.status,
      workMode: employee.workMode,
      roleLevel: employee.roleLevel,
      requiresLocationOnPunch: employee.requiresLocationOnPunch,
      trustedDeviceRequired: employee.trustedDeviceRequired,
      notes: employee.notes,
    );
  }

  JsonMap toApiJson() {
    return {
      'name': name,
      'role': role,
      'department': department,
      'email': email,
      'phone': phone,
      'unit': unit,
      'expectedShift': expectedShift,
      'status': employeeStatusToApi(status),
      'workMode': employeeWorkModeToApi(workMode),
      'roleLevel': roleLevelToApi(roleLevel),
      'requiresLocationOnPunch': requiresLocationOnPunch,
      'trustedDeviceRequired': trustedDeviceRequired,
      'notes': notes,
    };
  }
}
