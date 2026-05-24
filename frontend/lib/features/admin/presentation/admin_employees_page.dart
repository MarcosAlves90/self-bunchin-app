import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/core/forms/br_input_masks.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/shared/presentation/widgets/workspace_shell.dart';
import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'admin_employees_page_widgets.dart';

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key, this.api});

  final BunchinApi? api;

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  final TextEditingController _searchController = TextEditingController();

  late final BunchinApi _api;
  late List<EmployeeProfile> _employees;
  AuthContext? _authContext;
  _EmployeeDetailTab _detailTab = _EmployeeDetailTab.registration;
  EmployeeFilter _filter = EmployeeFilter.all;
  String _searchQuery = '';
  String? _selectedEmployeeId;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? BunchinApi();
    _employees = <EmployeeProfile>[];
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final employeesFuture = _api.listEmployees();
      final authContextFuture = _loadAuthContextSafely();
      final employees = await employeesFuture;
      final authContext = await authContextFuture;
      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
        _authContext = authContext;
        if (_selectedEmployeeId == null && _employees.isNotEmpty) {
          _selectedEmployeeId = _employees.first.id;
        }
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = 'Não foi possível carregar os funcionários.';
      });
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeProfile> get _visibleEmployees {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final currentUserEmail = _authContext?.user.email.trim().toLowerCase();
    final currentUserEmployeeId = _authContext?.user.employeeId;

    return _employees.where((employee) {
      // Avoid showing the current user's own profile in the admin list.
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

      final matchesFilter = switch (_filter) {
        EmployeeFilter.all => true,
        EmployeeFilter.active => employee.status == EmployeeStatus.active,
        EmployeeFilter.attention => _needsAttention(employee),
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
        final leftPriority = _needsAttention(left) ? 0 : 1;
        final rightPriority = _needsAttention(right) ? 0 : 1;

        if (leftPriority != rightPriority) {
          return leftPriority.compareTo(rightPriority);
        }

        return left.name.compareTo(right.name);
      });
  }

  EmployeeProfile? get _selectedEmployee {
    final visibleEmployees = _visibleEmployees;
    if (visibleEmployees.isEmpty) {
      return null;
    }

    for (final employee in visibleEmployees) {
      if (employee.id == _selectedEmployeeId) {
        return employee;
      }
    }

    return visibleEmployees.first;
  }

  int get _activeEmployees {
    return _employees
        .where((employee) => employee.status == EmployeeStatus.active)
        .length;
  }

  int get _attentionEmployees {
    return _employees.where(_needsAttention).length;
  }

  int get _locationTrackedEmployees {
    return _employees
        .where((employee) => employee.requiresLocationOnPunch)
        .length;
  }

  int get _leadershipEmployees {
    return _employees
        .where((employee) => employee.roleLevel == RoleLevel.leadership)
        .length;
  }

  bool _needsAttention(EmployeeProfile employee) {
    return employee.pendingAdjustments > 0 ||
        employee.status == EmployeeStatus.onboarding ||
        employee.status == EmployeeStatus.onLeave ||
        employee.status == EmployeeStatus.inactive;
  }

  Future<void> _openCreateEmployeeDialog() async {
    final draft = await showDialog<EmployeeDraft>(
      context: context,
      builder: (context) => const _EmployeeEditorDialog(),
    );

    if (draft == null || !mounted) {
      return;
    }

    try {
      final employee = await _api.createEmployee(draft);
      if (!mounted) {
        return;
      }

      setState(() {
        _employees = <EmployeeProfile>[employee, ..._employees];
        _selectedEmployeeId = employee.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${employee.name} foi adicionado à empresa.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _openEditEmployeeDialog(EmployeeProfile employee) async {
    final draft = await showDialog<EmployeeDraft>(
      context: context,
      builder: (context) => _EmployeeEditorDialog(employee: employee),
    );

    if (draft == null || !mounted) {
      return;
    }

    try {
      final updated = await _api.updateEmployee(employee.id, draft);
      if (!mounted) {
        return;
      }

      setState(() {
        _employees = _employees.map((currentEmployee) {
          if (currentEmployee.id != employee.id) {
            return currentEmployee;
          }

          return updated;
        }).toList();
        _selectedEmployeeId = employee.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${draft.name} foi atualizado com sucesso.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _removeSelectedEmployee() async {
    final employee = _selectedEmployee;
    if (employee == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover funcionário'),
          content: Text(
            'Deseja remover ${employee.name}? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _api.deleteEmployee(employee.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _employees = _employees
            .where((currentEmployee) => currentEmployee.id != employee.id)
            .toList();
        final fallbackSelection =
            _visibleEmployees.isEmpty ? null : _visibleEmployees.first.id;
        _selectedEmployeeId = fallbackSelection;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${employee.name} foi removido da empresa.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  void _selectEmployee(String employeeId) {
    setState(() {
      _selectedEmployeeId = employeeId;
    });
  }

  String _formatHours(int minutes) {
    final hours = (minutes ~/ 60).toString().padLeft(2, '0');
    final remainingMinutes = (minutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${remainingMinutes}m';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  Color _statusColor(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.active => const Color(0xFF2F8F46),
      EmployeeStatus.onboarding => const Color(0xFF8C5D00),
      EmployeeStatus.onLeave => const Color(0xFF8C5D00),
      EmployeeStatus.inactive => const Color(0xFF8B1E1E),
    };
  }

  String _statusLabel(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.active => 'Ativo',
      EmployeeStatus.onboarding => 'Onboarding',
      EmployeeStatus.onLeave => 'Afastado',
      EmployeeStatus.inactive => 'Inativo',
    };
  }

  String _workModeLabel(EmployeeWorkMode workMode) {
    return switch (workMode) {
      EmployeeWorkMode.onsite => 'Presencial',
      EmployeeWorkMode.hybrid => 'Híbrido',
      EmployeeWorkMode.remote => 'Remoto',
    };
  }

  IconData _statusIcon(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.active => Icons.check_circle_rounded,
      EmployeeStatus.onboarding => Icons.rocket_launch_rounded,
      EmployeeStatus.onLeave => Icons.pause_circle_rounded,
      EmployeeStatus.inactive => Icons.do_not_disturb_on_rounded,
    };
  }

  String _filterLabel(EmployeeFilter filter) {
    return switch (filter) {
      EmployeeFilter.all => 'Todos',
      EmployeeFilter.active => 'Ativos',
      EmployeeFilter.attention => 'Atenção',
      EmployeeFilter.inactive => 'Inativos',
    };
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      sidebar: _buildSummaryPanel(),
      contentBuilder: (context, isWide) => _buildWorkspace(isWide: isWide),
    );
  }

  Widget _buildSummaryPanel() {
    final company = _authContext?.company;
    final companyName = _companyDisplayName(company);
    final companyIdentity = _companyIdentitySummary(company);

    return WorkspaceSidebar(
      title: 'Painel administrativo da empresa.',
      description:
          'Acompanhe equipe, pendências e regras operacionais em um só lugar.',
      summaryChildren: <Widget>[
        WorkspaceSummaryStripe(
          label: 'Empresa',
          value: companyName,
          helper: companyIdentity,
        ),
        WorkspaceSummaryStripe(
          label: 'Headcount',
          value: '${_employees.length} funcionários',
          helper: '$_activeEmployees ativos e $_leadershipEmployees lideranças',
        ),
        WorkspaceSummaryStripe(
          label: 'Pendências',
          value: '$_attentionEmployees em atenção',
          helper: 'Onboarding, afastamentos e ajustes',
        ),
      ],
      highlightChips: _buildSidebarHighlightChips(),
    );
  }

  List<Widget> _buildSidebarHighlightChips() {
    final workspaceAccessLabel =
        _authContext?.user.workspaceAccessLabel ?? 'Acesso autenticado';
    return <Widget>[
      WorkspaceHighlightChip(
        label: workspaceAccessLabel,
      ),
      const WorkspaceHighlightChip(label: 'Dados mascarados'),
    ];
  }

  String _companyDisplayName(AuthCompanySummary? company) {
    if (company == null) {
      return 'Cadastro empresarial indisponível';
    }

    final tradeName = company.tradeName.trim();
    if (tradeName.isNotEmpty) {
      return tradeName;
    }

    return company.legalName.trim();
  }

  String _companyIdentitySummary(AuthCompanySummary? company) {
    if (company == null) {
      return 'Não foi possível carregar os dados cadastrais da empresa.';
    }

    final legalName = company.legalName.trim();
    final displayName = _companyDisplayName(company);

    if (legalName.isNotEmpty && legalName != displayName) {
      return legalName;
    }

    return 'Dados cadastrais confirmados.';
  }

  Widget _buildWorkspace({required bool isWide}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 24, 28, isWide ? 32 : 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildWorkspaceHeader(isWide),
          const SizedBox(height: 16),
          _buildMetricGrid(isWide),
          const SizedBox(height: 20),
          _buildEmployeesSection(isWide),
        ],
      ),
    );
  }

  Widget _buildWorkspaceHeader(bool isWide) {
    if (!isWide) {
      return WorkspaceHeader(
        title: 'Administrar equipe',
        description: '',
        maxContentWidth: 620,
        actions: _buildHeaderActions(false),
      );
    }

    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'Administrar equipe',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ..._buildHeaderActions(true),
      ],
    );
  }

  List<Widget> _buildHeaderActions(bool isWide) {
    final selectedEmployee = _selectedEmployee;
    final removeButton = SizedBox(
      width: isWide ? 240 : double.infinity,
      child: OutlinedButton.icon(
        onPressed: selectedEmployee == null ? null : _removeSelectedEmployee,
        icon: const Icon(Icons.person_remove_alt_1_rounded),
        label: const Text('Remover selecionado'),
        style: _removeButtonStyle(),
      ),
    );
    final createButton = SizedBox(
      width: isWide ? 210 : double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openCreateEmployeeDialog,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Novo funcionário'),
      ),
    );

    if (!isWide) {
      return <Widget>[createButton, removeButton];
    }

    return <Widget>[removeButton, const SizedBox(width: 8), createButton];
  }

  ButtonStyle _removeButtonStyle() {
    final colorScheme = Theme.of(context).colorScheme;
    final criticalColor = colorScheme.error;
    return OutlinedButton.styleFrom(
      foregroundColor: criticalColor,
      side: BorderSide(color: criticalColor.withValues(alpha: 0.45)),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return criticalColor.withValues(alpha: 0.18);
        }
        if (states.contains(WidgetState.hovered)) {
          return criticalColor.withValues(alpha: 0.1);
        }
        return null;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.surfaceContainerHighest.withValues(alpha: 0.42);
        }
        return criticalColor.withValues(alpha: 0.04);
      }),
    );
  }

  Widget _buildMetricGrid(bool isWide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleRow = isWide && constraints.maxWidth >= 980;
        final useTwoColumns = !useSingleRow && constraints.maxWidth >= 500;
        final itemWidth = useTwoColumns
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;
        final metricItems = <Widget>[
          _AdminMetricItem(
            icon: Icons.groups_2_rounded,
            label: 'Colaboradores',
            value: _employees.length.toString(),
          ),
          _AdminMetricItem(
            icon: Icons.verified_user_rounded,
            label: 'Ativos',
            value: _activeEmployees.toString(),
          ),
          _AdminMetricItem(
            icon: Icons.location_on_rounded,
            label: 'Com geolocalização',
            value: _locationTrackedEmployees.toString(),
          ),
          _AdminMetricItem(
            icon: Icons.warning_amber_rounded,
            label: 'Em atenção',
            value: _attentionEmployees.toString(),
          ),
        ];

        return useSingleRow
            ? Row(
                children: metricItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == metricItems.length - 1 ? 0 : 8,
                      ),
                      child: item,
                    ),
                  );
                }).toList(),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: metricItems
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: item,
                      ),
                    )
                    .toList(),
              );
      },
    );
  }

  Widget _buildEmployeesSection(bool isWide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSplitLayout = isWide && constraints.maxWidth >= 980;

        if (useSplitLayout) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 11, child: _buildEmployeesListCard()),
              const SizedBox(width: 20),
              Expanded(flex: 9, child: _buildEmployeeDetailCard()),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildEmployeesListCard(),
            const SizedBox(height: 20),
            _buildEmployeeDetailCard(),
          ],
        );
      },
    );
  }

  Widget _buildEmployeesListCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleEmployees = _visibleEmployees;

    return WorkspaceSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Equipe',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Busque e selecione perfis para editar dados principais.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Buscar funcionário',
              hintText: 'Nome, cargo ou unidade',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: EmployeeFilter.values.map((filter) {
              return ChoiceChip(
                label: Text(_filterLabel(filter)),
                selected: _filter == filter,
                checkmarkColor: AppTheme.accent,
                onSelected: (_) {
                  setState(() {
                    _filter = filter;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_loadError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _loadError!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _loadEmployees,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          else if (visibleEmployees.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nenhum funcionário encontrado.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajuste os filtros ou cadastre um novo colaborador para continuar.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _openCreateEmployeeDialog,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Novo funcionário'),
                  ),
                ],
              ),
            )
          else
            Column(
              children: visibleEmployees.map((employee) {
                final selected = employee.id == _selectedEmployee?.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EmployeeListTile(
                    employee: employee,
                    selected: selected,
                    statusColor: _statusColor(employee.status),
                    statusIcon: _statusIcon(employee.status),
                    statusLabel: _statusLabel(employee.status),
                    needsAttention: _needsAttention(employee),
                    onTap: () => _selectEmployee(employee.id),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDetailCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final employee = _selectedEmployee;

    if (employee == null) {
      return WorkspaceSectionCard(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.touch_app_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Selecione um funcionário para ver os detalhes.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hasNotes = employee.notes.trim().isNotEmpty;
    final lastPunchLabel = employee.lastPunchAt == null
        ? 'Sem registro'
        : _formatDateTime(employee.lastPunchAt!);

    return WorkspaceSectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useTwoColumns = constraints.maxWidth >= 520;
          final overviewItemWidth = useTwoColumns
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          final activeTab = hasNotes || _detailTab != _EmployeeDetailTab.notes
              ? _detailTab
              : _EmployeeDetailTab.registration;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _EmployeeDetailHero(
                employee: employee,
                statusLabel: _statusLabel(employee.status),
                statusColor: _statusColor(employee.status),
                statusIcon: _statusIcon(employee.status),
                workModeLabel: _workModeLabel(employee.workMode),
                workModeIcon: _workModeSummaryIcon(employee.workMode),
                needsAttention: _needsAttention(employee),
                onEdit: () => _openEditEmployeeDialog(employee),
              ),
              const SizedBox(height: 12),
              Text(
                'Resumo rápido',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  SizedBox(
                    width: overviewItemWidth,
                    child: _EmployeeOverviewCard(
                      icon: Icons.schedule_rounded,
                      label: 'Jornada',
                      value: employee.expectedShiftLabel,
                    ),
                  ),
                  SizedBox(
                    width: overviewItemWidth,
                    child: _EmployeeOverviewCard(
                      icon: Icons.av_timer_rounded,
                      label: 'Horas de hoje',
                      value: _formatHours(employee.todayWorkedMinutes),
                    ),
                  ),
                  SizedBox(
                    width: overviewItemWidth,
                    child: _EmployeeOverviewCard(
                      icon: Icons.history_toggle_off_rounded,
                      label: 'Última batida',
                      value: lastPunchLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailTabSelector(
                activeTab: activeTab,
                hasNotes: hasNotes,
                useVerticalLayout: constraints.maxWidth < 360,
              ),
              const SizedBox(height: 12),
              if (activeTab == _EmployeeDetailTab.registration)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.82),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: <Widget>[
                      _EmployeeDetailRow(
                        icon: Icons.alternate_email_rounded,
                        label: 'E-mail',
                        value: employee.email,
                      ),
                      Divider(color: colorScheme.outlineVariant, height: 1),
                      _EmployeeDetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefone',
                        value: employee.phone,
                      ),
                    ],
                  ),
                )
              else if (activeTab == _EmployeeDetailTab.policies)
                Column(
                  children: <Widget>[
                    _EmployeePolicyRow(
                      icon: Icons.location_searching_rounded,
                      title: 'Validação de localização',
                      value: employee.requiresLocationOnPunch
                          ? 'Obrigatória nas batidas'
                          : 'Flexível para a operação',
                      tone: employee.requiresLocationOnPunch
                          ? const Color(0xFF1F4E79)
                          : const Color(0xFF6B6254),
                    ),
                    const SizedBox(height: 10),
                    _EmployeePolicyRow(
                      icon: Icons.verified_user_outlined,
                      title: 'Dispositivo confiável',
                      value: employee.trustedDeviceRequired
                          ? 'Exigido para registrar ponto'
                          : 'Sem restrição ativa',
                      tone: employee.trustedDeviceRequired
                          ? const Color(0xFF2F8F46)
                          : const Color(0xFF6B6254),
                    ),
                    const SizedBox(height: 10),
                    _EmployeePolicyRow(
                      icon: employee.pendingAdjustments > 0
                          ? Icons.warning_amber_rounded
                          : Icons.task_alt_rounded,
                      title: 'Ajustes pendentes',
                      value: employee.pendingAdjustments > 0
                          ? '${employee.pendingAdjustments} aguardando revisão'
                          : 'Nenhum ajuste em aberto',
                      tone: employee.pendingAdjustments > 0
                          ? const Color(0xFF8C5D00)
                          : const Color(0xFF2F8F46),
                    ),
                  ],
                )
              else
                _EmployeeNarrativeCard(
                  icon: Icons.sticky_note_2_outlined,
                  label: 'Notas da gestão',
                  value: employee.notes,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailTabSelector({
    required _EmployeeDetailTab activeTab,
    required bool hasNotes,
    required bool useVerticalLayout,
  }) {
    const tabItems = <({
      _EmployeeDetailTab value,
      IconData icon,
      String label,
    })>[
      (
        value: _EmployeeDetailTab.registration,
        icon: Icons.badge_outlined,
        label: 'Cadastro',
      ),
      (
        value: _EmployeeDetailTab.policies,
        icon: Icons.policy_outlined,
        label: 'Políticas',
      ),
      (
        value: _EmployeeDetailTab.notes,
        icon: Icons.notes_rounded,
        label: 'Notas',
      ),
    ];
    final colorScheme = Theme.of(context).colorScheme;
    final visibleItems = tabItems
        .where((item) => hasNotes || item.value != _EmployeeDetailTab.notes)
        .toList();

    if (!useVerticalLayout) {
      return SegmentedButton<_EmployeeDetailTab>(
        segments: visibleItems
            .map(
              (item) => ButtonSegment<_EmployeeDetailTab>(
                value: item.value,
                icon: Icon(item.icon),
                label: Text(item.label),
              ),
            )
            .toList(),
        selected: <_EmployeeDetailTab>{activeTab},
        showSelectedIcon: false,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.accent;
            }

            return null;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }

            return null;
          }),
          side:
              const WidgetStatePropertyAll(BorderSide(color: AppTheme.accent)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        onSelectionChanged: (selection) {
          setState(() {
            _detailTab = selection.first;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: visibleItems.map((item) {
        final selected = item.value == activeTab;
        return Padding(
          padding: EdgeInsets.only(bottom: item == visibleItems.last ? 0 : 8),
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _detailTab = item.value;
              });
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: selected ? AppTheme.accent : null,
              foregroundColor:
                  selected ? colorScheme.onPrimary : colorScheme.onSurface,
              side: const BorderSide(color: AppTheme.accent),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            icon: Icon(item.icon),
            label: Text(item.label),
          ),
        );
      }).toList(),
    );
  }

  IconData _workModeSummaryIcon(EmployeeWorkMode workMode) {
    return switch (workMode) {
      EmployeeWorkMode.onsite => Icons.business_center_rounded,
      EmployeeWorkMode.hybrid => Icons.sync_alt_rounded,
      EmployeeWorkMode.remote => Icons.laptop_mac_rounded,
    };
  }
}

enum _EmployeeDetailTab { registration, policies, notes }
