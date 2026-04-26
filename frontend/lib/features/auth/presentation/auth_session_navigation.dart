import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:bunchin_flutter/features/time_tracking/presentation/time_clock_page.dart';
import 'package:flutter/material.dart';

Route<void> buildAuthenticatedWorkspaceRoute(AuthSession session) {
  if (session.user.isAdmin || !session.user.hasEmployeeProfile) {
    return MaterialPageRoute<void>(
      builder: (_) => const AdminEmployeesPage(),
    );
  }

  return MaterialPageRoute<void>(
    builder: (_) => const TimeClockPage(),
  );
}
