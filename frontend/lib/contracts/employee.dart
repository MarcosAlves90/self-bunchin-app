import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';

enum EmployeeFilter { all, active, attention, inactive }

enum EmployeeStatus { active, onboarding, onLeave, inactive }

enum EmployeeWorkMode { onsite, hybrid, remote }

enum RoleLevel { staff, specialist, leadership }

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

}