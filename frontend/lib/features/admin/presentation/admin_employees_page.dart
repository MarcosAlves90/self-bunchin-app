import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/core/forms/br_input_masks.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/shared/presentation/widgets/workspace_shell.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_controller.dart';
import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'admin_employees_page_widgets.dart';

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key, this.api, this.controller});

  final BunchinApi? api;
  final AdminEmployeesController? controller;

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  late final AdminEmployeesController _controller;
  late final bool _ownsController;
  _EmployeeDetailTab _detailTab = _EmployeeDetailTab.registration;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        AdminEmployeesController(api: widget.api);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openCreateEmployeeDialog() async {
    final draft = await showDialog<EmployeeDraft>(
      context: context,
      builder: (context) => const _EmployeeEditorDialog(),
    );

    if (draft == null || !mounted) {
      return;
    }

    final message = await _controller.createEmployee(draft);
    if (!mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openEditEmployeeDialog(EmployeeProfile employee) async {
    final draft = await showDialog<EmployeeDraft>(
      context: context,
      builder: (context) => _EmployeeEditorDialog(employee: employee),
    );

    if (draft == null || !mounted) {
      return;
    }

    final message = await _controller.updateEmployee(employee, draft);
    if (!mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _removeSelectedEmployee() async {
    final employee = _controller.selectedEmployee;
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

    final message = await _controller.deleteSelectedEmployee();
    if (!mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _selectEmployee(String employeeId) {
    _controller.selectEmployee(employeeId);
  }

  Future<void> _loadEmployees() => _controller.loadEmployees();

  TextEditingController get _searchController => _controller.searchController;
  List<EmployeeProfile> get _employees => _controller.employees;
  AuthContext? get _authContext => _controller.authContext;
  EmployeeFilter get _filter => _controller.filter;
  String get _searchQuery => _controller.searchQuery;
  String? get _selectedEmployeeId => _controller.selectedEmployeeId;
  bool get _isLoading => _controller.isLoading;
  String? get _loadError => _controller.loadError;
  EmployeeProfile? get _selectedEmployee => _controller.selectedEmployee;
  List<EmployeeProfile> get _visibleEmployees => _controller.visibleEmployees;
  int get _activeEmployees => _controller.activeEmployees;
  int get _attentionEmployees => _controller.attentionEmployees;
  int get _locationTrackedEmployees => _controller.locationTrackedEmployees;
  int get _leadershipEmployees => _controller.leadershipEmployees;

  bool _needsAttention(EmployeeProfile employee) {
    return _controller.needsAttention(employee);
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
    return _controller.statusColor(status);
  }

  String _statusLabel(EmployeeStatus status) {
    return _controller.statusLabel(status);
  }

  String _workModeLabel(EmployeeWorkMode workMode) {
    return _controller.workModeLabel(workMode);
  }

  IconData _statusIcon(EmployeeStatus status) {
    return _controller.statusIcon(status);
  }

  String _filterLabel(EmployeeFilter filter) {
    return _controller.filterLabel(filter);
  }

  String _companyDisplayName(AuthCompanySummary? company) {
    return _controller.companyDisplayName(company);
  }

  String _companyIdentitySummary(AuthCompanySummary? company) {
    return _controller.companyIdentitySummary(company);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return WorkspaceScaffold(
          sidebar: _buildSummaryPanel(),
          contentBuilder: (context, isWide) => _buildWorkspace(isWide: isWide),
        );
      },
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
              _controller.setSearchQuery(value);
            },
            decoration: InputDecoration(
              labelText: 'Buscar funcionário',
              hintText: 'Nome, cargo ou unidade',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clearSearch();
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
                  _controller.setFilter(filter);
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
    return _controller.workModeSummaryIcon(workMode);
  }
}

enum _EmployeeDetailTab { registration, policies, notes }
