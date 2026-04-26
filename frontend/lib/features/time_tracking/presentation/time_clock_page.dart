import 'dart:async';

import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/shared/presentation/widgets/workspace_shell.dart';
import 'package:bunchin_flutter/features/time_tracking/application/punch_location_service.dart';
import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TimeClockPage extends StatefulWidget {
  const TimeClockPage({super.key});

  @override
  State<TimeClockPage> createState() => _TimeClockPageState();
}

class _TimeClockPageState extends State<TimeClockPage> {
  final BunchinApi _api = BunchinApi();
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

  final PunchLocationService _punchLocationService =
      const PunchLocationService();

  late DateTime _now;
  late List<PunchRecord> _records;
  late ShiftStatus _status;
  Timer? _clockTimer;
  PunchLocationResult _locationState = const PunchLocationResult.checking();
  bool _isSubmittingPunch = false;
  bool _isLoadingState = true;
  String? _loadError;
  String _employeeName = 'Funcionario';
  String _employeeUnit = '-';
  int _todayWorkedMinutes = 0;
  int _todayBreakMinutes = 0;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _records = <PunchRecord>[];
    _status = ShiftStatus.checkedOut;
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareLocationAccess());
      unawaited(_loadTimeClockState());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimeClockState() async {
    setState(() {
      _isLoadingState = true;
      _loadError = null;
    });

    try {
      final state = await _api.getMyTimeClockState();
      if (!mounted) {
        return;
      }

      setState(() {
        _employeeName = state.employee.name;
        _employeeUnit = state.employee.unit;
        _status = state.currentStatus;
        _todayWorkedMinutes = state.todayWorkedMinutes;
        _todayBreakMinutes = state.todayBreakMinutes;
        _records = state.records;
        _isLoadingState = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingState = false;
        _loadError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingState = false;
        _loadError = 'Nao foi possivel carregar o estado de ponto.';
      });
    }
  }

  Future<void> _prepareLocationAccess() async {
    final result = await _punchLocationService.requestPermission();
    if (!mounted) {
      return;
    }

    setState(() {
      _locationState = result;
    });
  }

  Future<void> _handlePunch(PunchType type) async {
    if (_isSubmittingPunch) {
      return;
    }

    setState(() {
      _isSubmittingPunch = true;
    });

    final locationResult = await _punchLocationService.captureForPunch();
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmittingPunch = false;
      _locationState = locationResult;
    });

    final location = locationResult.snapshot;
    if (location == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locationResult.message)));
      return;
    }

    await _registerPunch(type, location: location);
  }

  Future<void> _registerPunch(
    PunchType type, {
    required PunchLocationSnapshot location,
  }) async {
    try {
      final punch = await _api.createPunch(
        request: CreatePunchRequest(type: type, location: location),
      );
      await _loadTimeClockState();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${punch.title} registrado com sucesso.')),
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

  PunchRecord? get _firstCheckIn {
    for (final record in _records) {
      if (record.type == PunchType.checkIn) {
        return record;
      }
    }
    return null;
  }

  PunchRecord? get _lastRecord => _records.isEmpty ? null : _records.last;

  PunchLocationSnapshot? get _lastRegisteredLocation {
    for (final record in _records.reversed) {
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
    return WorkspaceScaffold(
      sidebar: _buildSummaryPanel(),
      contentBuilder: (context, isWide) => _buildWorkspace(isWide: isWide),
    );
  }

  Widget _buildSummaryPanel() {
    return WorkspaceSidebar(
      title: 'Ponto digital em tempo real.',
      description:
          'Uma tela operacional para registrar entrada, pausa e saída com localização vinculada a cada batida.',
      summaryChildren: <Widget>[
        WorkspaceSummaryStripe(
          label: 'Status',
          value: _statusLabel(),
          helper: _statusDescription(),
        ),
        WorkspaceSummaryStripe(
          label: 'Funcionário',
          value: _employeeName,
          helper: _employeeUnit,
        ),
        WorkspaceSummaryStripe(
          label: 'Última batida',
          value: _lastRecord == null
              ? '--:--'
              : _formatTime(_lastRecord!.timestamp),
          helper: _lastRecord?.title ?? 'Nenhum registro no dia',
        ),
      ],
      highlightChips: <Widget>[
        WorkspaceHighlightChip(label: _locationChipLabel()),
        const WorkspaceHighlightChip(label: 'Dispositivo confiável'),
        const WorkspaceHighlightChip(label: 'Jornada auditável'),
      ],
    );
  }

  Widget _buildWorkspace({required bool isWide}) {
    if (_isLoadingState) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
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
          _buildContextCard(),
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
                value: _firstCheckIn == null
                    ? '--:--'
                    : _formatTime(_firstCheckIn!.timestamp),
                helper: 'Primeiro registro válido de hoje',
              ),
            ),
            SizedBox(
              width: width,
              child: WorkspaceMetricCard(
                label: 'Útimo evento',
                value: _lastRecord == null
                    ? '--:--'
                    : _formatTime(_lastRecord!.timestamp),
                helper: _lastRecord?.title ?? 'Sem eventos registrados',
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
            'Histórico cronolóco das batidas com contexto suficiente para auditoria operacional.',
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
                for (var index = 0; index < _records.length; index++) ...[
                  _TimelineTile(record: _records[index]),
                  if (index < _records.length - 1)
                    Divider(color: colorScheme.outlineVariant, height: 20),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContextCard() {
    final lastLocation = _lastRegisteredLocation;

    return WorkspaceSectionCard(
      child: Wrap(
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
            label: 'Precisã',
            value: lastLocation == null
                ? '--'
                : _formatAccuracy(lastLocation.accuracyMeters),
          ),
          const _InfoFlag(label: 'Modo', value: 'Presencial rastreado'),
        ],
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
                  'Precisã estimada ${location.accuracyMeters.toStringAsFixed(0)} m',
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
