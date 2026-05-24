part of 'admin_employees_page.dart';

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
  late final TextEditingController _expectedShiftStartController;
  late final TextEditingController _expectedShiftEndController;
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
            expectedShiftStart: TimeOfDay(hour: 8, minute: 0),
            expectedShiftEnd: TimeOfDay(hour: 17, minute: 0),
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
    _expectedShiftStartController = TextEditingController(
      text: _formatTimeOfDay(draft.expectedShiftStart),
    );
    _expectedShiftEndController = TextEditingController(
      text: _formatTimeOfDay(draft.expectedShiftEnd),
    );
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
    _expectedShiftStartController.dispose();
    _expectedShiftEndController.dispose();
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
        expectedShiftStart: _parseTimeOfDay(_expectedShiftStartController.text),
        expectedShiftEnd: _parseTimeOfDay(_expectedShiftEndController.text),
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildShiftTimeField(
                          controller: _expectedShiftStartController,
                          label: 'Entrada prevista',
                          onTap: () => _pickShiftTime(
                            controller: _expectedShiftStartController,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildShiftTimeField(
                          controller: _expectedShiftEndController,
                          label: 'Saída prevista',
                          onTap: () => _pickShiftTime(
                            controller: _expectedShiftEndController,
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildShiftTimeField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:mm',
        prefixIcon: const Icon(Icons.schedule_rounded),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) {
          return 'Informe um horário válido.';
        }
        final match = RegExp(r'^\d{2}:\d{2}$').hasMatch(trimmedValue);
        if (!match) {
          return 'Use o formato HH:mm.';
        }
        return null;
      },
    );
  }

  Future<void> _pickShiftTime({
    required TextEditingController controller,
  }) async {
    final initialTime = controller.text.trim().isEmpty
        ? const TimeOfDay(hour: 8, minute: 0)
        : _parseTimeOfDay(controller.text);
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (selectedTime == null) {
      return;
    }
    controller.text = _formatTimeOfDay(selectedTime);
  }

  String _formatTimeOfDay(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.trim().split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
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
    required this.statusIcon,
    required this.statusLabel,
    required this.needsAttention,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final EmployeeProfile employee;
  final bool selected;
  final Color statusColor;
  final IconData statusIcon;
  final String statusLabel;
  final bool needsAttention;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
          padding: const EdgeInsets.all(14),
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
              return _buildContent(
                context,
                theme,
                colorScheme,
                isCompact: isCompact,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required bool isCompact,
  }) {
    final hasSignals =
        employee.status != EmployeeStatus.active || needsAttention;
    final showLeadingIcon = MediaQuery.sizeOf(context).width >= 560;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (showLeadingIcon) ...<Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.accent.withValues(alpha: 0.16)
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.72,
                        ),
                  border: Border.all(
                    color: selected
                        ? AppTheme.accent.withValues(alpha: 0.36)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Icon(
                  Icons.badge_rounded,
                  size: 24,
                  color: selected ? AppTheme.accent : colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          employee.name,
                          maxLines: isCompact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onEdit,
                        tooltip: 'Editar funcionário',
                        icon: const Icon(Icons.edit_outlined),
                        color: AppTheme.accent,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'Remover funcionário',
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: const Color(0xFFE53935),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ],
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
          ],
        ),
        if (hasSignals) ...<Widget>[
          const SizedBox(height: 12),
          _buildBadgeWrap(),
        ],
      ],
    );
  }

  Widget _buildBadgeWrap() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        if (employee.status != EmployeeStatus.active)
          _InlinePill(
            label: statusLabel,
            tone: statusColor,
            icon: statusIcon,
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

class _EmployeeDetailHero extends StatelessWidget {
  const _EmployeeDetailHero({
    required this.employee,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.workModeLabel,
    required this.workModeIcon,
    required this.needsAttention,
    required this.onEdit,
  });

  final EmployeeProfile employee;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final String workModeLabel;
  final IconData workModeIcon;
  final bool needsAttention;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showIdentityIcon = MediaQuery.sizeOf(context).width >= 560;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.82),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;
          final identityBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (showIdentityIcon) ...<Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.28)),
                  ),
                  child: Icon(
                    Icons.manage_accounts_rounded,
                    size: 28,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Perfil selecionado',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _InlinePill(
                          label: statusLabel,
                          tone: statusColor,
                          icon: statusIcon,
                        ),
                        _InlinePill(
                          label: workModeLabel,
                          tone: colorScheme.onSurfaceVariant,
                          icon: workModeIcon,
                        ),
                        if (needsAttention)
                          const _InlinePill(
                            label: 'Atenção operacional',
                            tone: Color(0xFF8C5D00),
                            icon: Icons.priority_high_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      employee.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.role} | ${employee.department}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.apartment_rounded,
                          size: 15,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            employee.unit,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                identityBlock,
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: identityBlock),
              const SizedBox(width: 12),
              SizedBox(
                width: 128,
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmployeeNarrativeCard extends StatelessWidget {
  const _EmployeeNarrativeCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.54),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
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

class _EmployeeOverviewCard extends StatelessWidget {
  const _EmployeeOverviewCard({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.82),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.88),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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

class _EmployeeDetailRow extends StatelessWidget {
  const _EmployeeDetailRow({
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

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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

class _EmployeePolicyRow extends StatelessWidget {
  const _EmployeePolicyRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.82),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              border: Border.all(color: tone.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 18, color: tone),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    height: 1.4,
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
