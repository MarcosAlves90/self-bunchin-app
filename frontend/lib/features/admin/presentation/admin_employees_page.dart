import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/core/forms/br_input_masks.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/shared/presentation/widgets/workspace_shell.dart';
import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  final BunchinApi _api = BunchinApi();
  final TextEditingController _searchController = TextEditingController();

  late List<EmployeeProfile> _employees;
  EmployeeFilter _filter = EmployeeFilter.all;
  String _searchQuery = '';
  String? _selectedEmployeeId;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _employees = <EmployeeProfile>[];
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final employees = await _api.listEmployees();
      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeProfile> get _visibleEmployees {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return _employees.where((employee) {
      // Don't show the current user in the admin list
      if (employee.name == 'Marina Costa') {
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

  Color _workModeColor(EmployeeWorkMode workMode) {
    return switch (workMode) {
      EmployeeWorkMode.onsite => const Color(0xFF1F4E79),
      EmployeeWorkMode.hybrid => const Color(0xFF6A4FB3),
      EmployeeWorkMode.remote => const Color(0xFF2B6F60),
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

  IconData _workModeIcon(EmployeeWorkMode workMode) {
    return switch (workMode) {
      EmployeeWorkMode.onsite => Icons.business_rounded,
      EmployeeWorkMode.hybrid => Icons.home_work_rounded,
      EmployeeWorkMode.remote => Icons.laptop_mac_rounded,
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
    return WorkspaceSidebar(
      title: 'Painel administrativo da empresa.',
      description:
          'Centralize equipe, onboarding e políticas operacionais em uma visão única de gestão.',
      summaryChildren: <Widget>[
        const WorkspaceSummaryStripe(
          label: 'Empresa',
          value: 'Bunchin Serviços Digitais',
          helper: '4 unidades e operação com RH centralizado',
        ),
        WorkspaceSummaryStripe(
          label: 'Headcount',
          value: '${_employees.length} funcionários',
          helper:
              '$_activeEmployees ativos e $_leadershipEmployees lideranças cadastradas',
        ),
        WorkspaceSummaryStripe(
          label: 'Pendências',
          value: '$_attentionEmployees em atenção',
          helper: 'Onboarding, afastamentos e ajustes de ponto',
        ),
      ],
      highlightChips: const <Widget>[
        WorkspaceHighlightChip(label: 'Cadastro auditável'),
        WorkspaceHighlightChip(label: 'Políticas por equipe'),
        WorkspaceHighlightChip(label: 'Pronto para RH'),
      ],
    );
  }

  Widget _buildWorkspace({required bool isWide}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 24, 28, isWide ? 32 : 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WorkspaceHeader(
            title: 'Administrar equipe',
            description:
                'Visualize funcionários, revise pendências operacionais e ajuste cadastros sem sair do contexto do produto.',
            maxContentWidth: 620,
          ),
          const SizedBox(height: 28),
          _buildHeroCard(isWide),
          const SizedBox(height: 20),
          _buildMetricGrid(isWide),
          const SizedBox(height: 20),
          _buildEmployeesSection(isWide),
        ],
      ),
    );
  }

  Widget _buildHeroCard(bool isWide) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WorkspaceSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.16),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(Icons.groups_2_rounded),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const WorkspaceStatusBadge(
                      label: 'Administração ativa',
                      tone: Color(0xFF1F4E79),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Equipe operacional sob controle.',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 0.98,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_attentionEmployees colaboradores exigem revisão. O restante segue dentro das políticas configuradas.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              SizedBox(
                width: isWide ? 240 : double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openCreateEmployeeDialog,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Novo funcionário'),
                ),
              ),
              SizedBox(
                width: isWide ? 240 : double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectedEmployee == null
                      ? null
                      : () => _openEditEmployeeDialog(_selectedEmployee!),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar selecionado'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(bool isWide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
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
            'Funcionários da empresa',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Busque, filtre e selecione perfis para editar dados mestres e políticas operacionais.',
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
              hintText: 'Nome, cargo, unidade ou e-mail',
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
                    workModeColor: _workModeColor(employee.workMode),
                    statusIcon: _statusIcon(employee.status),
                    workModeIcon: _workModeIcon(employee.workMode),
                    statusLabel: _statusLabel(employee.status),
                    workModeLabel: _workModeLabel(employee.workMode),
                    needsAttention: _needsAttention(employee),
                    formattedLastPunch: employee.lastPunchAt == null
                        ? 'Sem batida recente'
                        : _formatDateTime(employee.lastPunchAt!),
                    formattedTodayHours: _formatHours(
                      employee.todayWorkedMinutes,
                    ),
                    onTap: () => _selectEmployee(employee.id),
                    onEdit: () => _openEditEmployeeDialog(employee),
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
        child: Text(
          'Selecione um funcionário para ver o detalhe do cadastro.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return WorkspaceSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    WorkspaceStatusBadge(
                      label: _statusLabel(employee.status),
                      tone: _statusColor(employee.status),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      employee.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${employee.role} | ${employee.department}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 148,
                child: OutlinedButton.icon(
                  onPressed: () => _openEditEmployeeDialog(employee),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            employee.notes,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _InfoFlag(label: 'E-mail', value: employee.email),
              _InfoFlag(label: 'Telefone', value: employee.phone),
              _InfoFlag(label: 'Unidade', value: employee.unit),
              _InfoFlag(label: 'Jornada', value: employee.expectedShift),
              _InfoFlag(
                label: 'Modo',
                value: _workModeLabel(employee.workMode),
              ),
              _InfoFlag(
                label: 'Última batida',
                value: employee.lastPunchAt == null
                    ? 'Sem registro'
                    : _formatDateTime(employee.lastPunchAt!),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.82),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Políticas e conformidade',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _PolicyChip(
                      label: employee.requiresLocationOnPunch
                          ? 'Localização obrigatória'
                          : 'Sem geolocalização obrigatória',
                      tone: employee.requiresLocationOnPunch
                          ? const Color(0xFF1F4E79)
                          : const Color(0xFF6B6254),
                    ),
                    _PolicyChip(
                      label: employee.trustedDeviceRequired
                          ? 'Dispositivo confiável exigido'
                          : 'Dispositivo livre',
                      tone: employee.trustedDeviceRequired
                          ? const Color(0xFF2F8F46)
                          : const Color(0xFF6B6254),
                    ),
                    _PolicyChip(
                      label: '${employee.pendingAdjustments} ajustes pendentes',
                      tone: employee.pendingAdjustments > 0
                          ? const Color(0xFF8C5D00)
                          : const Color(0xFF2F8F46),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Horas trabalhadas hoje: ${_formatHours(employee.todayWorkedMinutes)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeEditorDialog extends StatefulWidget {
  const _EmployeeEditorDialog({this.employee});

  final EmployeeProfile? employee;

  @override
  State<_EmployeeEditorDialog> createState() => _EmployeeEditorDialogState();
}

class _EmployeeEditorDialogState extends State<_EmployeeEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _departmentController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _unitController;
  late final TextEditingController _expectedShiftController;
  late final TextEditingController _notesController;

  late EmployeeStatus _status;
  late EmployeeWorkMode _workMode;
  late RoleLevel _roleLevel;
  late bool _requiresLocationOnPunch;
  late bool _trustedDeviceRequired;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final draft = widget.employee == null
        ? const EmployeeDraft(
            name: '',
            role: '',
            department: '',
            email: '',
            phone: '',
            unit: '',
            expectedShift: '',
            status: EmployeeStatus.active,
            workMode: EmployeeWorkMode.onsite,
            roleLevel: RoleLevel.staff,
            requiresLocationOnPunch: true,
            trustedDeviceRequired: true,
            notes: '',
          )
        : EmployeeDraft.fromEmployee(widget.employee!);

    _nameController = TextEditingController(text: draft.name);
    _roleController = TextEditingController(text: draft.role);
    _departmentController = TextEditingController(text: draft.department);
    _emailController = TextEditingController(text: draft.email);
    _phoneController = TextEditingController(
      text: BrInputMasks.formatPhone(draft.phone),
    );
    _unitController = TextEditingController(text: draft.unit);
    _expectedShiftController = TextEditingController(text: draft.expectedShift);
    _notesController = TextEditingController(text: draft.notes);
    _status = draft.status;
    _workMode = draft.workMode;
    _roleLevel = draft.roleLevel;
    _requiresLocationOnPunch = draft.requiresLocationOnPunch;
    _trustedDeviceRequired = draft.trustedDeviceRequired;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _unitController.dispose();
    _expectedShiftController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      EmployeeDraft(
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        department: _departmentController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        unit: _unitController.text.trim(),
        expectedShift: _expectedShiftController.text.trim(),
        status: _status,
        workMode: _workMode,
        roleLevel: _roleLevel,
        requiresLocationOnPunch: _requiresLocationOnPunch,
        trustedDeviceRequired: _trustedDeviceRequired,
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _isEditing ? 'Editar funcionário' : 'Novo funcionário',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Atualize dados mestres, políticas de ponto e contexto operacional do colaborador.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nome completo',
                    hintText: 'Ex.: Maria da Silva',
                    icon: Icons.person_outline_rounded,
                    validatorMessage: 'Informe o nome do funcionário.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _roleController,
                    label: 'Cargo',
                    hintText: 'Ex.: Analista Financeira',
                    icon: Icons.badge_outlined,
                    validatorMessage: 'Informe o cargo principal.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _departmentController,
                    label: 'Departamento',
                    hintText: 'Ex.: Financeiro',
                    icon: Icons.apartment_rounded,
                    validatorMessage: 'Informe o departamento.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail corporativo',
                      hintText: 'Ex.: maria@empresa.com.br',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@') ||
                          !value.contains('.')) {
                        return 'Informe um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefone',
                    hintText: 'Ex.: (11) 99999-0000',
                    icon: Icons.phone_outlined,
                    validatorMessage: 'Informe um telefone com DDD.',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [BrInputMasks.phoneFormatter],
                    validator: (value) {
                      final trimmedValue = value?.trim() ?? '';
                      if (trimmedValue.isEmpty) {
                        return 'Informe um telefone com DDD.';
                      }
                      if (!BrInputMasks.hasValidPhoneDigits(trimmedValue)) {
                        return 'Use um telefone com 10 ou 11 dígitos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _unitController,
                    label: 'Unidade',
                    hintText: 'Ex.: Matriz Paulista',
                    icon: Icons.location_city_outlined,
                    validatorMessage: 'Informe a unidade de referência.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _expectedShiftController,
                    label: 'Jornada prevista',
                    hintText: 'Ex.: 08:00 às 17:00',
                    icon: Icons.schedule_rounded,
                    validatorMessage: 'Informe a jornada prevista.',
                  ),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(),
                  const SizedBox(height: 16),
                  _buildWorkModeDropdown(),
                  const SizedBox(height: 16),
                  _buildRoleDropdown(),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _requiresLocationOnPunch,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Exigir localização no registro de ponto',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _requiresLocationOnPunch = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    value: _trustedDeviceRequired,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Restringir a dispositivo confiável'),
                    onChanged: (value) {
                      setState(() {
                        _trustedDeviceRequired = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Contexto administrativo',
                      hintText: 'Ex.: Responsável pela operação da unidade.',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(
                                _isEditing
                                    ? 'Salvar alterações'
                                    : 'Criar funcionário',
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                          ],
                        );
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          SizedBox(
                            width: 220,
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(
                                _isEditing
                                    ? 'Salvar alterações'
                                    : 'Criar funcionário',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    required IconData icon,
    required String validatorMessage,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String? value)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().length < 3) {
              return validatorMessage;
            }
            return null;
          },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<EmployeeStatus>(
      initialValue: _status,
      decoration: const InputDecoration(
        labelText: 'Status do colaborador',
        prefixIcon: Icon(Icons.flag_outlined),
      ),
      items: EmployeeStatus.values.map((status) {
        return DropdownMenuItem<EmployeeStatus>(
          value: status,
          child: Text(_statusLabelForForm(status)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _status = value;
        });
      },
    );
  }

  Widget _buildWorkModeDropdown() {
    return DropdownButtonFormField<EmployeeWorkMode>(
      initialValue: _workMode,
      decoration: const InputDecoration(
        labelText: 'Modo de trabalho',
        prefixIcon: Icon(Icons.work_outline_rounded),
      ),
      items: EmployeeWorkMode.values.map((workMode) {
        return DropdownMenuItem<EmployeeWorkMode>(
          value: workMode,
          child: Text(_workModeLabelForForm(workMode)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _workMode = value;
        });
      },
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<RoleLevel>(
      initialValue: _roleLevel,
      decoration: const InputDecoration(
        labelText: 'Nível de acesso',
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items: RoleLevel.values.map((roleLevel) {
        return DropdownMenuItem<RoleLevel>(
          value: roleLevel,
          child: Text(_roleLevelLabel(roleLevel)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _roleLevel = value;
        });
      },
    );
  }
}

String _statusLabelForForm(EmployeeStatus status) {
  return switch (status) {
    EmployeeStatus.active => 'Ativo',
    EmployeeStatus.onboarding => 'Onboarding',
    EmployeeStatus.onLeave => 'Afastado',
    EmployeeStatus.inactive => 'Inativo',
  };
}

String _workModeLabelForForm(EmployeeWorkMode workMode) {
  return switch (workMode) {
    EmployeeWorkMode.onsite => 'Presencial',
    EmployeeWorkMode.hybrid => 'Híbrido',
    EmployeeWorkMode.remote => 'Remoto',
  };
}

String _roleLevelLabel(RoleLevel roleLevel) {
  return switch (roleLevel) {
    RoleLevel.staff => 'Operacional',
    RoleLevel.specialist => 'Especialista',
    RoleLevel.leadership => 'Liderança',
  };
}

class _EmployeeListTile extends StatelessWidget {
  const _EmployeeListTile({
    required this.employee,
    required this.selected,
    required this.statusColor,
    required this.workModeColor,
    required this.statusIcon,
    required this.workModeIcon,
    required this.statusLabel,
    required this.workModeLabel,
    required this.needsAttention,
    required this.formattedLastPunch,
    required this.formattedTodayHours,
    required this.onTap,
    required this.onEdit,
  });

  final EmployeeProfile employee;
  final bool selected;
  final Color statusColor;
  final Color workModeColor;
  final IconData statusIcon;
  final IconData workModeIcon;
  final String statusLabel;
  final String workModeLabel;
  final bool needsAttention;
  final String formattedLastPunch;
  final String formattedTodayHours;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accent.withValues(alpha: 0.08)
                : colorScheme.surface.withValues(alpha: 0.8),
            border: Border.all(
              color: selected ? AppTheme.accent : colorScheme.outlineVariant,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 560;
              return _buildContent(theme, colorScheme, isCompact: isCompact);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    ColorScheme colorScheme, {
    required bool isCompact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    employee.name,
                    maxLines: isCompact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${employee.role} | ${employee.department}',
                    maxLines: isCompact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              splashRadius: 20,
              tooltip: 'Editar funcionário',
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildBadgeWrap(),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Icon(
              Icons.alternate_email_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                employee.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildMetaSection(isCompact: isCompact),
      ],
    );
  }

  Widget _buildBadgeWrap() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        _InlinePill(
          label: statusLabel,
          tone: statusColor,
          icon: statusIcon,
        ),
        _InlinePill(
          label: workModeLabel,
          tone: workModeColor,
          icon: workModeIcon,
        ),
        if (employee.requiresLocationOnPunch)
          const _InlinePill(
            label: 'Local obrigatório',
            tone: Color(0xFF1F4E79),
            icon: Icons.location_on_rounded,
          ),
        if (needsAttention)
          const _InlinePill(
            label: 'Acompanhamento',
            tone: Color(0xFF8C5D00),
            icon: Icons.warning_amber_rounded,
          ),
      ],
    );
  }

  Widget _buildMetaSection({required bool isCompact}) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _EmployeeMetaChip(
            icon: Icons.schedule_rounded,
            label: 'Hoje',
            value: formattedTodayHours,
            fullWidth: true,
          ),
          const SizedBox(height: 8),
          _EmployeeMetaChip(
            icon: Icons.access_time_rounded,
            label: 'Última batida',
            value: formattedLastPunch,
            fullWidth: true,
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _EmployeeMetaChip(
          icon: Icons.schedule_rounded,
          label: 'Hoje',
          value: formattedTodayHours,
        ),
        _EmployeeMetaChip(
          icon: Icons.access_time_rounded,
          label: 'Última batida',
          value: formattedLastPunch,
        ),
      ],
    );
  }
}

class _EmployeeMetaChip extends StatelessWidget {
  const _EmployeeMetaChip({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          if (fullWidth)
            Expanded(
              child: Text(
                '$label: $value',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              '$label: $value',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminMetricItem extends StatelessWidget {
  const _AdminMetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.58),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoFlag extends StatelessWidget {
  const _InfoFlag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyChip extends StatelessWidget {
  const _PolicyChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
      ),
      child: Text(label),
    );
  }
}

class _InlinePill extends StatelessWidget {
  const _InlinePill({
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final Color tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: tone),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
