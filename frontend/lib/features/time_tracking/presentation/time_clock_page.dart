import 'dart:async';

import 'package:bunchin_flutter/contracts/location.dart';
import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/features/shared/presentation/widgets/pagination_controls.dart';
import 'package:bunchin_flutter/features/shared/presentation/widgets/workspace_shell.dart';
import 'package:bunchin_flutter/features/time_tracking/presentation/time_clock_controller.dart';
import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TimeClockPage extends StatefulWidget {
  const TimeClockPage({super.key, this.controller});

  final TimeClockController? controller;

  @override
  State<TimeClockPage> createState() => _TimeClockPageState();
}

class _TimeClockPageState extends State<TimeClockPage> {
  static const List<String> _weekdays = <String>[
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];

  static const List<String> _months = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  late final TimeClockController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TimeClockController();
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

  DateTime get _now => _controller.now;
  List<PunchRecord> get _records => _controller.records;
  ShiftStatus get _status => _controller.status;
  PunchLocationResult get _locationState => _controller.locationState;
  bool get _isSubmittingPunch => _controller.isSubmittingPunch;
  bool get _isLoadingState => _controller.isLoadingState;
  String? get _loadError => _controller.loadError;
  String get _employeeName => _controller.employeeName;
  String get _employeeUnit => _controller.employeeUnit;
  int get _todayWorkedMinutes => _controller.todayWorkedMinutes;
  int get _todayBreakMinutes => _controller.todayBreakMinutes;
  DateTime? get _firstCheckInAt => _controller.firstCheckInAt;
  DateTime? get _lastPunchAt => _controller.lastPunchAt;

  Future<void> _loadTimeClockState() => _controller.loadTimeClockState(
        page: _controller.recordsPage,
        limit: _controller.recordsPageSize,
      );

  Future<void> _prepareLocationAccess() => _controller.prepareLocationAccess();

  Future<void> _handlePunch(PunchType type) async {
    final message = await _controller.handlePunch(type);
    if (!mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  PunchLocationSnapshot? get _lastRegisteredLocation {
    for (final record in _records) {
      final location = record.location;
      if (location != null) {
        return location;
      }
    }
    return null;
  }

  String _formatClock(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    final ss = value.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDate(DateTime value) {
    return '${_weekdays[value.weekday - 1]}, ${value.day} de ${_months[value.month - 1]}';
  }

  String _formatDuration(Duration value) {
    final hh = value.inHours.toString().padLeft(2, '0');
    final mm = (value.inMinutes % 60).toString().padLeft(2, '0');
    return '${hh}h ${mm}m';
  }

  String _formatCoordinate(double value) {
    return value.toStringAsFixed(5);
  }

  String _formatAccuracy(double value) {
    return '${value.toStringAsFixed(0)} m';
  }

  String _statusLabel() {
    return switch (_status) {
      ShiftStatus.checkedOut => 'Fora do turno',
      ShiftStatus.working => 'Em jornada',
      ShiftStatus.onBreak => 'Em pausa',
    };
  }

  String _statusDescription() {
    return switch (_status) {
      ShiftStatus.checkedOut =>
        'Nenhuma jornada ativa. O próximo registro deve ser a entrada.',
      ShiftStatus.working => 'Jornada em andamento com dispositivo validado.',
      ShiftStatus.onBreak =>
        'Pausa aberta. O próximo registro recomendado é o retorno.',
    };
  }

  Color _statusColor() {
    return switch (_status) {
      ShiftStatus.checkedOut => const Color(0xFF6B6254),
      ShiftStatus.working => const Color(0xFF2F8F46),
      ShiftStatus.onBreak => const Color(0xFF8C5D00),
    };
  }

  String _locationStatusLabel() {
    return switch (_locationState.status) {
      PunchLocationStatus.checking => 'Validando localização',
      PunchLocationStatus.ready => _lastRegisteredLocation == null
          ? 'Permissão ativa'
          : 'Localização pronta',
      PunchLocationStatus.serviceDisabled => 'Localização desativada',
      PunchLocationStatus.permissionDenied => 'Permissão negada',
      PunchLocationStatus.permissionDeniedForever => 'Permissão bloqueada',
      PunchLocationStatus.unsupported => 'Geolocalização indisponível',
      PunchLocationStatus.error => 'Falha de localização',
    };
  }

  String _locationActionLabel() {
    return switch (_locationState.status) {
      PunchLocationStatus.checking => 'Atualizando',
      PunchLocationStatus.ready => 'Atualizar permissão',
      PunchLocationStatus.serviceDisabled => 'Tentar novamente',
      PunchLocationStatus.permissionDenied => 'Solicitar permissão',
      PunchLocationStatus.permissionDeniedForever => 'Revalidar acesso',
      PunchLocationStatus.unsupported => 'Tentar novamente',
      PunchLocationStatus.error => 'Tentar novamente',
    };
  }

  Color _locationStatusColor() {
    return switch (_locationState.status) {
      PunchLocationStatus.checking => const Color(0xFF6B6254),
      PunchLocationStatus.ready => const Color(0xFF2F8F46),
      PunchLocationStatus.serviceDisabled => const Color(0xFF8C5D00),
      PunchLocationStatus.permissionDenied => const Color(0xFF8C5D00),
      PunchLocationStatus.permissionDeniedForever => const Color(0xFF8B1E1E),
      PunchLocationStatus.unsupported => const Color(0xFF6B6254),
      PunchLocationStatus.error => const Color(0xFF8B1E1E),
    };
  }

  IconData _locationStatusIcon() {
    return switch (_locationState.status) {
      PunchLocationStatus.checking => Icons.my_location_rounded,
      PunchLocationStatus.ready => Icons.location_on_rounded,
      PunchLocationStatus.serviceDisabled => Icons.location_off_rounded,
      PunchLocationStatus.permissionDenied => Icons.location_disabled_rounded,
      PunchLocationStatus.permissionDeniedForever => Icons.gpp_maybe_outlined,
      PunchLocationStatus.unsupported => Icons.device_unknown_rounded,
      PunchLocationStatus.error => Icons.warning_amber_rounded,
    };
  }

  String _locationChipLabel() {
    return switch (_locationState.status) {
      PunchLocationStatus.ready => 'Geolocalização pronta',
      PunchLocationStatus.checking => 'Validando permissão',
      PunchLocationStatus.serviceDisabled => 'Ative a localização',
      PunchLocationStatus.permissionDenied => 'Permissão pendente',
      PunchLocationStatus.permissionDeniedForever => 'Permissão bloqueada',
      PunchLocationStatus.unsupported => 'Geolocalização indisponível',
      PunchLocationStatus.error => 'Falha de localização',
    };
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
    final isLoading = _isLoadingState;
    return WorkspaceSidebar(
      title: 'Ponto digital em tempo real.',
      description:
          'Uma tela operacional para registrar entrada, pausa e saída com localização vinculada a cada batida.',
      summaryChildren: <Widget>[
        WorkspaceSummaryStripe(
          label: 'Status',
          value: isLoading ? 'Carregando...' : _statusLabel(),
          helper: isLoading
              ? 'Buscando estado atual do ponto'
              : _statusDescription(),
        ),
        WorkspaceSummaryStripe(
          label: 'Funcionário',
          value: isLoading ? 'Carregando...' : _employeeName,
          helper: isLoading ? 'Sincronizando cadastro vinculado' : _employeeUnit,
        ),
        WorkspaceSummaryStripe(
          label: 'Última batida',
          value: isLoading
              ? 'Carregando...'
              : _lastPunchAt == null
                  ? '--:--'
                  : _formatTime(_lastPunchAt!),
          helper: isLoading
              ? 'Carregando histórico do dia'
              : _lastPunchAt == null
                  ? 'Nenhum registro no dia'
                  : 'Último evento recebido',
        ),
      ],
      highlightChips: <Widget>[
        WorkspaceHighlightChip(
          label: isLoading ? 'Sincronizando ponto' : _locationChipLabel(),
        ),
        const WorkspaceHighlightChip(label: 'Dispositivo confiável'),
        const WorkspaceHighlightChip(label: 'Jornada auditável'),
      ],
    );
  }

  Widget _buildWorkspace({required bool isWide}) {
    if (_isLoadingState) {
      return _buildLoadingWorkspace(isWide: isWide);
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: WorkspaceSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_loadError!),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadTimeClockState,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Recarregar'),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 24, 28, isWide ? 32 : 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WorkspaceHeader(
            title: 'Bater ponto',
            description:
                'Registre sua jornada com um fluxo direto, auditável e com coordenadas anexadas para validação operacional.',
            maxContentWidth: 520,
          ),
          const SizedBox(height: 28),
          _buildHeroCard(isWide),
          const SizedBox(height: 20),
          _buildMetricGrid(isWide),
          const SizedBox(height: 20),
          _buildTimelineCard(),
          const SizedBox(height: 20),
          _buildContextCard(isWide),
        ],
      ),
    );
  }

  Widget _buildLoadingWorkspace({required bool isWide}) {
    final horizontalPadding = isWide ? 32.0 : 24.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WorkspaceHeader(
            title: 'Bater ponto',
            description: 'Carregando estado de ponto e linha do tempo de hoje.',
            maxContentWidth: 520,
          ),
          const SizedBox(height: 28),
          _buildLoadingHeroCard(),
          const SizedBox(height: 20),
          _buildLoadingMetricGrid(isWide),
          const SizedBox(height: 20),
          _buildLoadingTimelineCard(),
          const SizedBox(height: 20),
          _buildLoadingContextCard(),
        ],
      ),
    );
  }

  Widget _buildLoadingHeroCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WorkspaceSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Carregando estado de ponto',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Buscando jornada, permissões e último evento registrado.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMetricGrid(bool isWide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Horas hoje',
                value: '--',
                helper: 'Carregando tempo em jornada',
              ),
            ),
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Pausa acumulada',
                value: '--',
                helper: 'Carregando intervalos do dia',
              ),
            ),
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Primeira entrada',
                value: '--:--',
                helper: 'Carregando primeira batida',
              ),
            ),
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Útimo evento',
                value: '--:--',
                helper: 'Carregando último evento',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingTimelineCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WorkspaceSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Jornada do dia',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Carregando linha do tempo e paginação.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const _LoadingTimelineLine(),
          const SizedBox(height: 12),
          const _LoadingTimelineLine(),
          const SizedBox(height: 12),
          const _LoadingTimelineLine(),
        ],
      ),
    );
  }

  Widget _buildLoadingContextCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WorkspaceSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Contexto operacional',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aguardando atualização da localização e dos metadados do turno.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const <Widget>[
              _LoadingContextLine(),
              SizedBox(height: 12),
              _LoadingContextLine(),
              SizedBox(height: 12),
              _LoadingContextLine(),
            ],
          ),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.16),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(Icons.fingerprint_rounded),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WorkspaceStatusBadge(
                      label: _statusLabel(),
                      tone: _statusColor(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatClock(_now),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 0.96,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDate(_now),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _statusDescription(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildLocationBanner(),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isWide ? 240 : double.infinity,
                child: _buildPrimaryActionButton(),
              ),
              SizedBox(
                width: isWide ? 220 : double.infinity,
                child: _buildSecondaryActionButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBanner() {
    final theme = Theme.of(context);
    final color = _locationStatusColor();
    final lastLocation = _lastRegisteredLocation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_locationStatusIcon(), color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _locationStatusLabel(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_isSubmittingPunch)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _locationState.message,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (lastLocation != null) ...[
            const SizedBox(height: 10),
            Text(
              'Última coordenada auditada: ${_formatCoordinate(lastLocation.latitude)}, ${_formatCoordinate(lastLocation.longitude)} | precisão ${_formatAccuracy(lastLocation.accuracyMeters)}',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (_locationState.status != PunchLocationStatus.ready) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _isSubmittingPunch
                  ? null
                  : () {
                      unawaited(_prepareLocationAccess());
                    },
              icon: const Icon(Icons.my_location_rounded),
              label: Text(_locationActionLabel()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    if (_status == ShiftStatus.checkedOut) {
      return ElevatedButton.icon(
        onPressed: _isSubmittingPunch
            ? null
            : () {
                unawaited(_handlePunch(PunchType.checkIn));
              },
        icon: const Icon(Icons.login_rounded),
        label: const Text('Registrar entrada'),
      );
    }

    if (_status == ShiftStatus.working) {
      return ElevatedButton.icon(
        onPressed: _isSubmittingPunch
            ? null
            : () {
                unawaited(_handlePunch(PunchType.breakStart));
              },
        icon: const Icon(Icons.pause_circle_outline_rounded),
        label: const Text('Iniciar pausa'),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isSubmittingPunch
          ? null
          : () {
              unawaited(_handlePunch(PunchType.breakEnd));
            },
      icon: const Icon(Icons.play_circle_outline_rounded),
      label: const Text('Retomar jornada'),
    );
  }

  Widget _buildSecondaryActionButton() {
    if (_status == ShiftStatus.checkedOut) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Registrar saída'),
      );
    }

    return OutlinedButton.icon(
      onPressed: _isSubmittingPunch
          ? null
          : () {
              unawaited(_handlePunch(PunchType.checkOut));
            },
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Registrar saída'),
    );
  }

  Widget _buildMetricGrid(bool isWide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Horas hoje',
                value: _formatDuration(
                  Duration(minutes: _todayWorkedMinutes),
                ),
                helper: 'Tempo acumulado em jornada ativa',
              ),
            ),
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Pausa acumulada',
                value: _formatDuration(
                  Duration(minutes: _todayBreakMinutes),
                ),
                helper: 'Tempo total em intervalo no dia',
              ),
            ),
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Primeira entrada',
                value: _firstCheckInAt == null
                    ? '--:--'
                    : _formatTime(_firstCheckInAt!),
                helper: 'Primeiro registro válido de hoje',
              ),
            ),
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Útimo evento',
                value:
                    _lastPunchAt == null ? '--:--' : _formatTime(_lastPunchAt!),
                helper: _lastPunchAt == null
                    ? 'Sem eventos registrados'
                    : 'Último ponto enviado hoje',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPagination = _controller.hasTimelinePagination;
    final visibleRecords = _records;

    return WorkspaceSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jornada do dia',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Histórico cronológico das batidas com contexto suficiente para auditoria operacional.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (_records.isEmpty)
            Text(
              'Nenhum registro realizado hoje.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < visibleRecords.length; index++) ...[
                  _TimelineTile(record: visibleRecords[index]),
                  if (index < visibleRecords.length - 1)
                    Divider(color: colorScheme.outlineVariant, height: 20),
                ],
                if (hasPagination) ...[
                  const SizedBox(height: 20),
                  PaginationControls(
                    page: _controller.recordsPage,
                    totalPages: _controller.recordsTotalPages,
                    hasPrevious: _controller.recordsHasPrevious,
                    hasNext: _controller.recordsHasNext,
                    onPrevious: _controller.loadPreviousTimelinePage,
                    onNext: _controller.loadNextTimelinePage,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContextCard(bool isWide) {
    final lastLocation = _lastRegisteredLocation;

    return WorkspaceSectionCard(
      child: isWide
          ? Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoFlag(label: 'Permissão', value: _locationStatusLabel()),
                _InfoFlag(
                  label: 'Última coordenada',
                  value: lastLocation == null
                      ? 'Aguardando batida'
                      : '${_formatCoordinate(lastLocation.latitude)}, ${_formatCoordinate(lastLocation.longitude)}',
                ),
                _InfoFlag(
                  label: 'Precisão',
                  value: lastLocation == null
                      ? '--'
                      : _formatAccuracy(lastLocation.accuracyMeters),
                ),
                const _InfoFlag(label: 'Modo', value: 'Presencial rastreado'),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoFlag(label: 'Permissão', value: _locationStatusLabel()),
                const SizedBox(height: 12),
                _InfoFlag(
                  label: 'Última coordenada',
                  value: lastLocation == null
                      ? 'Aguardando batida'
                      : '${_formatCoordinate(lastLocation.latitude)}, ${_formatCoordinate(lastLocation.longitude)}',
                ),
                const SizedBox(height: 12),
                _InfoFlag(
                  label: 'Precisão',
                  value: lastLocation == null
                      ? '--'
                      : _formatAccuracy(lastLocation.accuracyMeters),
                ),
                const SizedBox(height: 12),
                const _InfoFlag(label: 'Modo', value: 'Presencial rastreado'),
              ],
            ),
    );
  }
}

class _LoadingTimelineLine extends StatelessWidget {
  const _LoadingTimelineLine();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 14,
            width: 160,
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          Container(
            height: 10,
            width: 240,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _LoadingContextLine extends StatelessWidget {
  const _LoadingContextLine();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.record});

  final PunchRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hh = record.timestamp.hour.toString().padLeft(2, '0');
    final mm = record.timestamp.minute.toString().padLeft(2, '0');
    final location = record.location;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.14),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.24)),
          ),
          child: Icon(record.icon, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.detail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              if (location != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Lat ${location.latitude.toStringAsFixed(5)} | Long ${location.longitude.toStringAsFixed(5)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Precisão estimada ${location.accuracyMeters.toStringAsFixed(0)} m',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$hh:$mm',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
        children: [
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
