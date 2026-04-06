import 'dart:ui';

import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  final TextEditingController _searchController = TextEditingController();

  late List<_EmployeeProfile> _employees;
  _EmployeeFilter _filter = _EmployeeFilter.all;
  String _searchQuery = '';
  String? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    _employees = _buildInitialEmployees();
    _selectedEmployeeId = _employees.first.id;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_EmployeeProfile> get _visibleEmployees {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return _employees.where((employee) {
      final matchesFilter = switch (_filter) {
        _EmployeeFilter.all => true,
        _EmployeeFilter.active => employee.status == _EmployeeStatus.active,
        _EmployeeFilter.attention => _needsAttention(employee),
        _EmployeeFilter.inactive => employee.status == _EmployeeStatus.inactive,
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
    }).toList()..sort((left, right) {
      final leftPriority = _needsAttention(left) ? 0 : 1;
      final rightPriority = _needsAttention(right) ? 0 : 1;

      if (leftPriority != rightPriority) {
        return leftPriority.compareTo(rightPriority);
      }

      return left.name.compareTo(right.name);
    });
  }

  _EmployeeProfile? get _selectedEmployee {
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
        .where((employee) => employee.status == _EmployeeStatus.active)
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
        .where((employee) => employee.roleLevel == _RoleLevel.leadership)
        .length;
  }

  bool _needsAttention(_EmployeeProfile employee) {
    return employee.pendingAdjustments > 0 ||
        employee.status == _EmployeeStatus.onboarding ||
        employee.status == _EmployeeStatus.onLeave ||
        employee.status == _EmployeeStatus.inactive;
  }

  Future<void> _openCreateEmployeeDialog() async {
    final draft = await showDialog<_EmployeeDraft>(
      context: context,
      builder: (context) => const _EmployeeEditorDialog(),
    );

    if (draft == null || !mounted) {
      return;
    }

    final employee = _EmployeeProfile.fromDraft(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      draft: draft,
    );

    setState(() {
      _employees = <_EmployeeProfile>[employee, ..._employees];
      _selectedEmployeeId = employee.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${employee.name} foi adicionado a empresa.')),
    );
  }

  Future<void> _openEditEmployeeDialog(_EmployeeProfile employee) async {
    final draft = await showDialog<_EmployeeDraft>(
      context: context,
      builder: (context) => _EmployeeEditorDialog(employee: employee),
    );

    if (draft == null || !mounted) {
      return;
    }

    setState(() {
      _employees = _employees.map((currentEmployee) {
        if (currentEmployee.id != employee.id) {
          return currentEmployee;
        }

        return currentEmployee.applyDraft(draft);
      }).toList();
      _selectedEmployeeId = employee.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${draft.name} foi atualizado com sucesso.')),
    );
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

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Color _statusColor(_EmployeeStatus status) {
    return switch (status) {
      _EmployeeStatus.active => const Color(0xFF2F8F46),
      _EmployeeStatus.onboarding => const Color(0xFF8C5D00),
      _EmployeeStatus.onLeave => const Color(0xFF8C5D00),
      _EmployeeStatus.inactive => const Color(0xFF8B1E1E),
    };
  }

  Color _workModeColor(_EmployeeWorkMode workMode) {
    return switch (workMode) {
      _EmployeeWorkMode.onsite => const Color(0xFF1F4E79),
      _EmployeeWorkMode.hybrid => const Color(0xFF6A4FB3),
      _EmployeeWorkMode.remote => const Color(0xFF2B6F60),
    };
  }

  String _statusLabel(_EmployeeStatus status) {
    return switch (status) {
      _EmployeeStatus.active => 'Ativo',
      _EmployeeStatus.onboarding => 'Onboarding',
      _EmployeeStatus.onLeave => 'Afastado',
      _EmployeeStatus.inactive => 'Inativo',
    };
  }

  String _workModeLabel(_EmployeeWorkMode workMode) {
    return switch (workMode) {
      _EmployeeWorkMode.onsite => 'Presencial',
      _EmployeeWorkMode.hybrid => 'Hibrido',
      _EmployeeWorkMode.remote => 'Remoto',
    };
  }

  String _filterLabel(_EmployeeFilter filter) {
    return switch (filter) {
      _EmployeeFilter.all => 'Todos',
      _EmployeeFilter.active => 'Ativos',
      _EmployeeFilter.attention => 'Atencao',
      _EmployeeFilter.inactive => 'Inativos',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.84),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -120,
              right: -40,
              child: _AmbientGlow(
                color: AppTheme.accent.withValues(alpha: 0.22),
                size: 280,
              ),
            ),
            Positioned(
              bottom: -120,
              left: -60,
              child: _AmbientGlow(
                color: colorScheme.secondary.withValues(alpha: 0.14),
                size: 260,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1080;

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.74),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: isWide
                            ? _buildWideLayout(constraints)
                            : _buildNarrowLayout(constraints),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _buildSummaryPanel(),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _buildWorkspace(isWide: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          children: <Widget>[
            _buildSummaryPanel(),
            _buildWorkspace(isWide: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppTheme.accent.withValues(alpha: 0.96),
            const Color(0xFFE28E00),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              'BUNCHIN',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Painel administrativo da empresa.',
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Centralize equipe, onboarding e politicas operacionais em uma visao unica de gestao.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.92),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          _SummaryStripe(
            label: 'Empresa',
            value: 'Bunchin Servicos Digitais',
            helper: '4 unidades e operacao com RH centralizado',
          ),
          const SizedBox(height: 16),
          _SummaryStripe(
            label: 'Headcount',
            value: '${_employees.length} funcionarios',
            helper:
                '$_activeEmployees ativos e $_leadershipEmployees liderancas cadastradas',
          ),
          const SizedBox(height: 16),
          _SummaryStripe(
            label: 'Pendencias',
            value: '$_attentionEmployees em atencao',
            helper: 'Onboarding, afastamentos e ajustes de ponto',
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const <Widget>[
              _HighlightChip(label: 'Cadastro auditavel'),
              _HighlightChip(label: 'Politicas por equipe'),
              _HighlightChip(label: 'Pronto para RH'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspace({required bool isWide}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 24, 28, isWide ? 32 : 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 12,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Administrar equipe',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visualize funcionarios, revise pendencias operacionais e ajuste cadastros sem sair do contexto do produto.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Voltar'),
              ),
            ],
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

    return _SectionCard(
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
                    const _StatusBadge(
                      label: 'Administracao ativa',
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
                      '$_attentionEmployees colaboradores exigem revisao. O restante segue dentro das politicas configuradas.',
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
                  label: const Text('Novo funcionario'),
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
        final width = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Total de colaboradores',
                value: _employees.length.toString(),
                helper: 'Base administrada pela empresa neste momento',
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Funcionarios ativos',
                value: _activeEmployees.toString(),
                helper: 'Pessoas em jornada regular e com acesso liberado',
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Geolocalizacao exigida',
                value: _locationTrackedEmployees.toString(),
                helper: 'Perfis com validacao de local no registro de ponto',
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Itens em atencao',
                value: _attentionEmployees.toString(),
                helper: 'Ajustes, onboarding ou perfis com risco operacional',
              ),
            ),
          ],
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

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Funcionarios da empresa',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Busque, filtre e selecione perfis para editar dados mestres e politicas operacionais.',
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
              labelText: 'Buscar funcionario',
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
            children: _EmployeeFilter.values.map((filter) {
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
          if (visibleEmployees.isEmpty)
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
                    'Nenhum funcionario encontrado.',
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
                    label: const Text('Novo funcionario'),
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
                    statusLabel: _statusLabel(employee.status),
                    workModeLabel: _workModeLabel(employee.workMode),
                    initials: _initialsFor(employee.name),
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
      return _SectionCard(
        child: Text(
          'Selecione um funcionario para ver o detalhe do cadastro.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return _SectionCard(
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
                    _StatusBadge(
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
                label: 'Ultima batida',
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
                  'Politicas e conformidade',
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
                          ? 'Localizacao obrigatoria'
                          : 'Sem geolocalizacao obrigatoria',
                      tone: employee.requiresLocationOnPunch
                          ? const Color(0xFF1F4E79)
                          : const Color(0xFF6B6254),
                    ),
                    _PolicyChip(
                      label: employee.trustedDeviceRequired
                          ? 'Dispositivo confiavel exigido'
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

  List<_EmployeeProfile> _buildInitialEmployees() {
    return <_EmployeeProfile>[
      _EmployeeProfile(
        id: 'emp-01',
        name: 'Marina Costa',
        role: 'Coordenadora de Operacoes',
        department: 'Operacoes',
        email: 'marina.costa@bunchin.com',
        phone: '(11) 99123-1001',
        unit: 'Unidade Paulista',
        expectedShift: '08:00 as 17:00',
        status: _EmployeeStatus.active,
        workMode: _EmployeeWorkMode.onsite,
        roleLevel: _RoleLevel.leadership,
        requiresLocationOnPunch: true,
        trustedDeviceRequired: true,
        todayWorkedMinutes: 447,
        pendingAdjustments: 0,
        lastPunchAt: DateTime.now().subtract(const Duration(minutes: 12)),
        notes:
            'Responsavel pela abertura da operacao e pela validacao das equipes presenciais.',
      ),
      _EmployeeProfile(
        id: 'emp-02',
        name: 'Caio Martins',
        role: 'Analista de RH',
        department: 'People Ops',
        email: 'caio.martins@bunchin.com',
        phone: '(11) 98888-2020',
        unit: 'Backoffice Centro',
        expectedShift: '09:00 as 18:00',
        status: _EmployeeStatus.active,
        workMode: _EmployeeWorkMode.hybrid,
        roleLevel: _RoleLevel.specialist,
        requiresLocationOnPunch: false,
        trustedDeviceRequired: true,
        todayWorkedMinutes: 392,
        pendingAdjustments: 2,
        lastPunchAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 8),
        ),
        notes:
            'Acompanha admissoes, desligamentos e ajustes de cadastro dos funcionarios.',
      ),
      _EmployeeProfile(
        id: 'emp-03',
        name: 'Bianca Nogueira',
        role: 'Fiscal de Loja',
        department: 'Campo',
        email: 'bianca.nogueira@bunchin.com',
        phone: '(11) 97777-3030',
        unit: 'Loja Santo Andre',
        expectedShift: '13:40 as 22:00',
        status: _EmployeeStatus.onLeave,
        workMode: _EmployeeWorkMode.onsite,
        roleLevel: _RoleLevel.staff,
        requiresLocationOnPunch: true,
        trustedDeviceRequired: true,
        todayWorkedMinutes: 0,
        pendingAdjustments: 1,
        lastPunchAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        notes:
            'Afastada temporariamente. RH precisa revisar escala e substituicao da unidade.',
      ),
      _EmployeeProfile(
        id: 'emp-04',
        name: 'Joao Pedro Lima',
        role: 'Desenvolvedor Flutter',
        department: 'Produto',
        email: 'joao.lima@bunchin.com',
        phone: '(11) 96666-4040',
        unit: 'Studio Digital',
        expectedShift: '09:00 as 18:00',
        status: _EmployeeStatus.active,
        workMode: _EmployeeWorkMode.remote,
        roleLevel: _RoleLevel.specialist,
        requiresLocationOnPunch: false,
        trustedDeviceRequired: false,
        todayWorkedMinutes: 421,
        pendingAdjustments: 0,
        lastPunchAt: DateTime.now().subtract(const Duration(minutes: 34)),
        notes:
            'Atua no app corporativo e em integracoes internas com foco em evolucao de produto.',
      ),
      _EmployeeProfile(
        id: 'emp-05',
        name: 'Larissa Araujo',
        role: 'Assistente Administrativa',
        department: 'Financeiro',
        email: 'larissa.araujo@bunchin.com',
        phone: '(11) 95555-5050',
        unit: 'Backoffice Centro',
        expectedShift: '08:30 as 17:30',
        status: _EmployeeStatus.onboarding,
        workMode: _EmployeeWorkMode.hybrid,
        roleLevel: _RoleLevel.staff,
        requiresLocationOnPunch: true,
        trustedDeviceRequired: false,
        todayWorkedMinutes: 0,
        pendingAdjustments: 3,
        lastPunchAt: null,
        notes:
            'Admissao em andamento. Falta concluir politica de localizacao e dispositivo confiavel.',
      ),
    ];
  }
}

enum _EmployeeFilter { all, active, attention, inactive }

enum _EmployeeStatus { active, onboarding, onLeave, inactive }

enum _EmployeeWorkMode { onsite, hybrid, remote }

enum _RoleLevel { staff, specialist, leadership }

class _EmployeeProfile {
  const _EmployeeProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.unit,
    required this.expectedShift,
    required this.status,
    required this.workMode,
    required this.roleLevel,
    required this.requiresLocationOnPunch,
    required this.trustedDeviceRequired,
    required this.todayWorkedMinutes,
    required this.pendingAdjustments,
    required this.lastPunchAt,
    required this.notes,
  });

  factory _EmployeeProfile.fromDraft({
    required String id,
    required _EmployeeDraft draft,
  }) {
    return _EmployeeProfile(
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
      pendingAdjustments: draft.status == _EmployeeStatus.onboarding ? 2 : 0,
      lastPunchAt: null,
      notes: draft.notes,
    );
  }

  final String id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final String unit;
  final String expectedShift;
  final _EmployeeStatus status;
  final _EmployeeWorkMode workMode;
  final _RoleLevel roleLevel;
  final bool requiresLocationOnPunch;
  final bool trustedDeviceRequired;
  final int todayWorkedMinutes;
  final int pendingAdjustments;
  final DateTime? lastPunchAt;
  final String notes;

  _EmployeeProfile applyDraft(_EmployeeDraft draft) {
    return _EmployeeProfile(
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

class _EmployeeDraft {
  const _EmployeeDraft({
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.unit,
    required this.expectedShift,
    required this.status,
    required this.workMode,
    required this.roleLevel,
    required this.requiresLocationOnPunch,
    required this.trustedDeviceRequired,
    required this.notes,
  });

  factory _EmployeeDraft.fromEmployee(_EmployeeProfile employee) {
    return _EmployeeDraft(
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

  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final String unit;
  final String expectedShift;
  final _EmployeeStatus status;
  final _EmployeeWorkMode workMode;
  final _RoleLevel roleLevel;
  final bool requiresLocationOnPunch;
  final bool trustedDeviceRequired;
  final String notes;
}

class _EmployeeEditorDialog extends StatefulWidget {
  const _EmployeeEditorDialog({this.employee});

  final _EmployeeProfile? employee;

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

  late _EmployeeStatus _status;
  late _EmployeeWorkMode _workMode;
  late _RoleLevel _roleLevel;
  late bool _requiresLocationOnPunch;
  late bool _trustedDeviceRequired;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final draft = widget.employee == null
        ? const _EmployeeDraft(
            name: '',
            role: '',
            department: '',
            email: '',
            phone: '',
            unit: '',
            expectedShift: '',
            status: _EmployeeStatus.active,
            workMode: _EmployeeWorkMode.onsite,
            roleLevel: _RoleLevel.staff,
            requiresLocationOnPunch: true,
            trustedDeviceRequired: true,
            notes: '',
          )
        : _EmployeeDraft.fromEmployee(widget.employee!);

    _nameController = TextEditingController(text: draft.name);
    _roleController = TextEditingController(text: draft.role);
    _departmentController = TextEditingController(text: draft.department);
    _emailController = TextEditingController(text: draft.email);
    _phoneController = TextEditingController(text: draft.phone);
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
      _EmployeeDraft(
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
                    _isEditing ? 'Editar funcionario' : 'Novo funcionario',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Atualize dados mestres, politicas de ponto e contexto operacional do colaborador.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nome completo',
                    icon: Icons.person_outline_rounded,
                    validatorMessage: 'Informe o nome do funcionario.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _roleController,
                    label: 'Cargo',
                    icon: Icons.badge_outlined,
                    validatorMessage: 'Informe o cargo principal.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _departmentController,
                    label: 'Departamento',
                    icon: Icons.apartment_rounded,
                    validatorMessage: 'Informe o departamento.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail corporativo',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@') ||
                          !value.contains('.')) {
                        return 'Informe um e-mail valido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefone',
                    icon: Icons.phone_outlined,
                    validatorMessage: 'Informe um telefone com DDD.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _unitController,
                    label: 'Unidade',
                    icon: Icons.location_city_outlined,
                    validatorMessage: 'Informe a unidade de referencia.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _expectedShiftController,
                    label: 'Jornada prevista',
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
                      'Exigir localizacao no registro de ponto',
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
                    title: const Text('Restringir a dispositivo confiavel'),
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
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
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
                                ? 'Salvar alteracoes'
                                : 'Criar funcionario',
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
    required IconData icon,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (value == null || value.trim().length < 3) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<_EmployeeStatus>(
      initialValue: _status,
      decoration: const InputDecoration(
        labelText: 'Status do colaborador',
        prefixIcon: Icon(Icons.flag_outlined),
      ),
      items: _EmployeeStatus.values.map((status) {
        return DropdownMenuItem<_EmployeeStatus>(
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
    return DropdownButtonFormField<_EmployeeWorkMode>(
      initialValue: _workMode,
      decoration: const InputDecoration(
        labelText: 'Modo de trabalho',
        prefixIcon: Icon(Icons.work_outline_rounded),
      ),
      items: _EmployeeWorkMode.values.map((workMode) {
        return DropdownMenuItem<_EmployeeWorkMode>(
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
    return DropdownButtonFormField<_RoleLevel>(
      initialValue: _roleLevel,
      decoration: const InputDecoration(
        labelText: 'Nivel de acesso',
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items: _RoleLevel.values.map((roleLevel) {
        return DropdownMenuItem<_RoleLevel>(
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

String _statusLabelForForm(_EmployeeStatus status) {
  return switch (status) {
    _EmployeeStatus.active => 'Ativo',
    _EmployeeStatus.onboarding => 'Onboarding',
    _EmployeeStatus.onLeave => 'Afastado',
    _EmployeeStatus.inactive => 'Inativo',
  };
}

String _workModeLabelForForm(_EmployeeWorkMode workMode) {
  return switch (workMode) {
    _EmployeeWorkMode.onsite => 'Presencial',
    _EmployeeWorkMode.hybrid => 'Hibrido',
    _EmployeeWorkMode.remote => 'Remoto',
  };
}

String _roleLevelLabel(_RoleLevel roleLevel) {
  return switch (roleLevel) {
    _RoleLevel.staff => 'Operacional',
    _RoleLevel.specialist => 'Especialista',
    _RoleLevel.leadership => 'Lideranca',
  };
}

class _EmployeeListTile extends StatelessWidget {
  const _EmployeeListTile({
    required this.employee,
    required this.selected,
    required this.statusColor,
    required this.workModeColor,
    required this.statusLabel,
    required this.workModeLabel,
    required this.initials,
    required this.needsAttention,
    required this.formattedLastPunch,
    required this.formattedTodayHours,
    required this.onTap,
    required this.onEdit,
  });

  final _EmployeeProfile employee;
  final bool selected;
  final Color statusColor;
  final Color workModeColor;
  final String statusLabel;
  final String workModeLabel;
  final String initials;
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.14),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.26),
                  ),
                ),
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      employee.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.role} | ${employee.department}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _InlinePill(label: statusLabel, tone: statusColor),
                        _InlinePill(label: workModeLabel, tone: workModeColor),
                        if (employee.requiresLocationOnPunch)
                          const _InlinePill(
                            label: 'Local obrigatorio',
                            tone: Color(0xFF1F4E79),
                          ),
                        if (needsAttention)
                          const _InlinePill(
                            label: 'Acompanhamento',
                            tone: Color(0xFF8C5D00),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      employee.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedTodayHours,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedLastPunch,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.56),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
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
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStripe extends StatelessWidget {
  const _SummaryStripe({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: tone,
          fontWeight: FontWeight.w700,
        ),
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
  const _InlinePill({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: tone,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
