import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:flutter/material.dart';

class AdminEmployeesController extends ChangeNotifier {
  AdminEmployeesController({BunchinApi? api}) : _api = api ?? BunchinApi();

  final BunchinApi _api;

  final TextEditingController searchController = TextEditingController();
  List<EmployeeProfile> employees = <EmployeeProfile>[];
  AuthContext? authContext;
  EmployeeFilter filter = EmployeeFilter.all;
  String searchQuery = '';
  String? selectedEmployeeId;
  List<ManagedPunchRecord> employeePunches = <ManagedPunchRecord>[];
  bool isLoadingEmployeePunches = false;
  String? employeePunchesError;
  bool isLoading = true;
  String? loadError;

  Future<void> start() async {
    await loadEmployees();
  }

  Future<void> loadEmployees() async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final employeesFuture = _api.listEmployees();
      final authContextFuture = _loadAuthContextSafely();
      final loadedEmployees = await employeesFuture;
      final loadedAuthContext = await authContextFuture;

      employees = loadedEmployees;
      authContext = loadedAuthContext;
      if (selectedEmployeeId == null && employees.isNotEmpty) {
        selectedEmployeeId = employees.first.id;
      }
      isLoading = false;
      notifyListeners();
      if (selectedEmployeeId != null) {
        await loadEmployeePunches(selectedEmployeeId!);
      }
    } on ApiException catch (error) {
      isLoading = false;
      loadError = error.message;
      notifyListeners();
    } catch (_) {
      isLoading = false;
      loadError = 'Não foi possível carregar os funcionários.';
      notifyListeners();
    }
  }

  Future<AuthContext?> _loadAuthContextSafely() async {
    try {
      return await _api.getAuthContext();
    } on ApiException {
      return null;
    } catch (_) {
      return null;
    }
  }

  List<EmployeeProfile> get visibleEmployees {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final currentUserEmail = authContext?.user.email.trim().toLowerCase();
    final currentUserEmployeeId = authContext?.user.employeeId;

    return employees.where((employee) {
      if (currentUserEmployeeId != null &&
          currentUserEmployeeId.isNotEmpty &&
          employee.id == currentUserEmployeeId) {
        return false;
      }

      if (currentUserEmail != null &&
          currentUserEmail.isNotEmpty &&
          employee.email.trim().toLowerCase() == currentUserEmail) {
        return false;
      }

      final matchesFilter = switch (filter) {
        EmployeeFilter.all => true,
        EmployeeFilter.active => employee.status == EmployeeStatus.active,
        EmployeeFilter.attention => needsAttention(employee),
        EmployeeFilter.inactive => employee.status == EmployeeStatus.inactive,
      };

      if (!matchesFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final haystack = <String>[
        employee.name,
        employee.role,
        employee.department,
        employee.email,
        employee.unit,
      ].join(' ').toLowerCase();

      return haystack.contains(normalizedQuery);
    }).toList()
      ..sort((left, right) {
        final leftPriority = needsAttention(left) ? 0 : 1;
        final rightPriority = needsAttention(right) ? 0 : 1;

        if (leftPriority != rightPriority) {
          return leftPriority.compareTo(rightPriority);
        }

        return left.name.compareTo(right.name);
      });
  }

  EmployeeProfile? get selectedEmployee {
    final visible = visibleEmployees;
    if (visible.isEmpty) {
      return null;
    }

    for (final employee in visible) {
      if (employee.id == selectedEmployeeId) {
        return employee;
      }
    }

    return visible.first;
  }

  int get activeEmployees {
    return employees
        .where((employee) => employee.status == EmployeeStatus.active)
        .length;
  }

  int get attentionEmployees {
    return employees.where(needsAttention).length;
  }

  int get locationTrackedEmployees {
    return employees
        .where((employee) => employee.requiresLocationOnPunch)
        .length;
  }

  int get leadershipEmployees {
    return employees
        .where((employee) => employee.roleLevel == RoleLevel.leadership)
        .length;
  }

  bool needsAttention(EmployeeProfile employee) {
    return employee.pendingAdjustments > 0 ||
        employee.status == EmployeeStatus.onboarding ||
        employee.status == EmployeeStatus.onLeave ||
        employee.status == EmployeeStatus.inactive;
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    notifyListeners();
  }

  void setFilter(EmployeeFilter value) {
    filter = value;
    notifyListeners();
  }

  void selectEmployee(String employeeId) {
    selectedEmployeeId = employeeId;
    notifyListeners();
  }

  Future<String?> createEmployee(EmployeeDraft draft) async {
    try {
      final employee = await _api.createEmployee(draft);
      employees = <EmployeeProfile>[employee, ...employees];
      selectedEmployeeId = employee.id;
      notifyListeners();
      await loadEmployeePunches(employee.id);
      return '${employee.name} foi adicionado à empresa.';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String?> updateEmployee(
    EmployeeProfile employee,
    EmployeeDraft draft,
  ) async {
    try {
      final updated = await _api.updateEmployee(employee.id, draft);
      employees = employees.map((currentEmployee) {
        if (currentEmployee.id != employee.id) {
          return currentEmployee;
        }

        return updated;
      }).toList();
      selectedEmployeeId = employee.id;
      notifyListeners();
      await loadEmployeePunches(employee.id);
      return '${draft.name} foi atualizado com sucesso.';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String?> deleteEmployee(EmployeeProfile employee) async {
    try {
      await _api.deleteEmployee(employee.id);
      employees = employees
          .where((currentEmployee) => currentEmployee.id != employee.id)
          .toList();
      final fallbackSelection =
          visibleEmployees.isEmpty ? null : visibleEmployees.first.id;
      selectedEmployeeId = fallbackSelection;
      notifyListeners();
      if (fallbackSelection == null) {
        employeePunches = <ManagedPunchRecord>[];
        employeePunchesError = null;
        isLoadingEmployeePunches = false;
        notifyListeners();
      } else {
        await loadEmployeePunches(fallbackSelection);
      }
      return '${employee.name} foi removido da empresa.';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<void> loadEmployeePunches(String employeeId) async {
    isLoadingEmployeePunches = true;
    employeePunchesError = null;
    notifyListeners();

    try {
      final punches = await _api.listManagedPunches(employeeId);
      if (selectedEmployeeId != employeeId) {
        return;
      }

      employeePunches = punches;
      isLoadingEmployeePunches = false;
      notifyListeners();
    } on ApiException catch (error) {
      if (selectedEmployeeId != employeeId) {
        return;
      }

      employeePunches = <ManagedPunchRecord>[];
      isLoadingEmployeePunches = false;
      employeePunchesError = error.message;
      notifyListeners();
    } catch (_) {
      if (selectedEmployeeId != employeeId) {
        return;
      }

      employeePunches = <ManagedPunchRecord>[];
      isLoadingEmployeePunches = false;
      employeePunchesError = 'Não foi possível carregar os pontos.';
      notifyListeners();
    }
  }

  Future<String?> createManagedPunch({
    required EmployeeProfile employee,
    required ManagedPunchDraft draft,
  }) async {
    try {
      await _api.createManagedPunch(employeeId: employee.id, draft: draft);
      await loadEmployeePunches(employee.id);
      return 'Ponto manual de ${employee.name} foi criado.';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String?> updateManagedPunch({
    required EmployeeProfile employee,
    required ManagedPunchRecord punch,
    required ManagedPunchDraft draft,
  }) async {
    try {
      await _api.updateManagedPunch(
        employeeId: employee.id,
        punchId: punch.id,
        draft: draft,
      );
      await loadEmployeePunches(employee.id);
      return 'Ponto manual atualizado.';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String?> deleteManagedPunch({
    required EmployeeProfile employee,
    required ManagedPunchRecord punch,
  }) async {
    try {
      await _api.deleteManagedPunch(
        employeeId: employee.id,
        punchId: punch.id,
      );
      await loadEmployeePunches(employee.id);
      return 'Ponto manual removido.';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  String filterLabel(EmployeeFilter value) {
    return switch (value) {
      EmployeeFilter.all => 'Todos',
      EmployeeFilter.active => 'Ativos',
      EmployeeFilter.attention => 'Atenção',
      EmployeeFilter.inactive => 'Inativos',
    };
  }

  String statusLabel(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.active => 'Ativo',
      EmployeeStatus.onboarding => 'Onboarding',
      EmployeeStatus.onLeave => 'Afastado',
      EmployeeStatus.inactive => 'Inativo',
    };
  }

  String workModeLabel(EmployeeWorkMode workMode) {
    return switch (workMode) {
      EmployeeWorkMode.onsite => 'Presencial',
      EmployeeWorkMode.hybrid => 'Híbrido',
      EmployeeWorkMode.remote => 'Remoto',
    };
  }

  Color statusColor(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.active => const Color(0xFF2F8F46),
      EmployeeStatus.onboarding => const Color(0xFF8C5D00),
      EmployeeStatus.onLeave => const Color(0xFF8C5D00),
      EmployeeStatus.inactive => const Color(0xFF8B1E1E),
    };
  }

  IconData statusIcon(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.active => Icons.check_circle_rounded,
      EmployeeStatus.onboarding => Icons.rocket_launch_rounded,
      EmployeeStatus.onLeave => Icons.pause_circle_rounded,
      EmployeeStatus.inactive => Icons.do_not_disturb_on_rounded,
    };
  }

  IconData workModeSummaryIcon(EmployeeWorkMode workMode) {
    return switch (workMode) {
      EmployeeWorkMode.onsite => Icons.business_center_rounded,
      EmployeeWorkMode.hybrid => Icons.sync_alt_rounded,
      EmployeeWorkMode.remote => Icons.laptop_mac_rounded,
    };
  }

  String companyDisplayName(AuthCompanySummary? company) {
    if (company == null) {
      return 'Cadastro empresarial indisponível';
    }

    final tradeName = company.tradeName.trim();
    if (tradeName.isNotEmpty) {
      return tradeName;
    }

    return company.legalName.trim();
  }

  String companyIdentitySummary(AuthCompanySummary? company) {
    if (company == null) {
      return 'Não foi possível carregar os dados cadastrais da empresa.';
    }

    final legalName = company.legalName.trim();
    final displayName = companyDisplayName(company);

    if (legalName.isNotEmpty && legalName != displayName) {
      return legalName;
    }

    return 'Dados cadastrais confirmados.';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
