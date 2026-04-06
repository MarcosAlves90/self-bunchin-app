import 'dart:async';
import 'dart:ui';

import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:bunchin_flutter/features/time_tracking/application/punch_location_service.dart';
import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TimeClockPage extends StatefulWidget {
  const TimeClockPage({super.key});

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

  final PunchLocationService _punchLocationService =
      const PunchLocationService();

  late DateTime _now;
  late List<_PunchRecord> _records;
  late _ShiftStatus _status;
  Timer? _clockTimer;
  PunchLocationResult _locationState = const PunchLocationResult.checking();
  bool _isSubmittingPunch = false;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _records = _buildInitialRecords(_now);
    _status = _deriveStatus(_records);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareLocationAccess());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
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

  Future<void> _handlePunch(_PunchType type) async {
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

    _registerPunch(type, location: location);
  }

  List<_PunchRecord> _buildInitialRecords(DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final records = <_PunchRecord>[];

    if (now.isAfter(startOfDay.add(const Duration(hours: 8, minutes: 5)))) {
      records.add(
        _PunchRecord(
          type: _PunchType.checkIn,
          timestamp: startOfDay.add(const Duration(hours: 8, minutes: 5)),
          detail: 'Entrada confirmada no dispositivo principal',
        ),
      );
    }

    if (now.isAfter(startOfDay.add(const Duration(hours: 12, minutes: 4)))) {
      records.add(
        _PunchRecord(
          type: _PunchType.breakStart,
          timestamp: startOfDay.add(const Duration(hours: 12, minutes: 4)),
          detail: 'Pausa iniciada para intervalo',
        ),
      );
    }

    if (now.isAfter(startOfDay.add(const Duration(hours: 12, minutes: 58)))) {
      records.add(
        _PunchRecord(
          type: _PunchType.breakEnd,
          timestamp: startOfDay.add(const Duration(hours: 12, minutes: 58)),
          detail: 'Retorno validado sem inconsistências',
        ),
      );
    }

    if (now.isAfter(startOfDay.add(const Duration(hours: 18, minutes: 2)))) {
      records.add(
        _PunchRecord(
          type: _PunchType.checkOut,
          timestamp: startOfDay.add(const Duration(hours: 18, minutes: 2)),
          detail: 'Saída registrada para encerramento do turno',
        ),
      );
    }

    return records;
  }

  _ShiftStatus _deriveStatus(List<_PunchRecord> records) {
    if (records.isEmpty) {
      return _ShiftStatus.checkedOut;
    }

    final lastType = records.last.type;
    if (lastType == _PunchType.checkIn || lastType == _PunchType.breakEnd) {
      return _ShiftStatus.working;
    }

    if (lastType == _PunchType.breakStart) {
      return _ShiftStatus.onBreak;
    }

    return _ShiftStatus.checkedOut;
  }

  void _registerPunch(
    _PunchType type, {
    required PunchLocationSnapshot location,
  }) {
    final detail = switch (type) {
      _PunchType.checkIn => 'Entrada registrada com localização validada',
      _PunchType.breakStart => 'Pausa iniciada com localização capturada',
      _PunchType.breakEnd => 'Jornada retomada com localização capturada',
      _PunchType.checkOut => 'Saída registrada com localização validada',
    };

    setState(() {
      _now = DateTime.now();
      _records = <_PunchRecord>[
        ..._records,
        _PunchRecord(
          type: type,
          timestamp: _now,
          detail: detail,
          location: location,
        ),
      ];
      _status = _deriveStatus(_records);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$detail. Coordenadas anexadas à auditoria.')),
    );
  }

  Duration _workedDuration() {
    var total = Duration.zero;
    DateTime? start;

    for (final record in _records) {
      if (record.type == _PunchType.checkIn ||
          record.type == _PunchType.breakEnd) {
        start ??= record.timestamp;
      }

      if ((record.type == _PunchType.breakStart ||
              record.type == _PunchType.checkOut) &&
          start != null) {
        total += record.timestamp.difference(start);
        start = null;
      }
    }

    if (_status == _ShiftStatus.working && start != null) {
      total += _now.difference(start);
    }

    return total;
  }

  Duration _breakDuration() {
    var total = Duration.zero;
    DateTime? start;

    for (final record in _records) {
      if (record.type == _PunchType.breakStart) {
        start = record.timestamp;
      }

      if ((record.type == _PunchType.breakEnd ||
              record.type == _PunchType.checkOut) &&
          start != null) {
        total += record.timestamp.difference(start);
        start = null;
      }
    }

    if (_status == _ShiftStatus.onBreak && start != null) {
      total += _now.difference(start);
    }

    return total;
  }

  _PunchRecord? get _firstCheckIn {
    for (final record in _records) {
      if (record.type == _PunchType.checkIn) {
        return record;
      }
    }
    return null;
  }

  _PunchRecord? get _lastRecord => _records.isEmpty ? null : _records.last;

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
      _ShiftStatus.checkedOut => 'Fora do turno',
      _ShiftStatus.working => 'Em jornada',
      _ShiftStatus.onBreak => 'Em pausa',
    };
  }

  String _statusDescription() {
    return switch (_status) {
      _ShiftStatus.checkedOut =>
        'Nenhuma jornada ativa. O próximo registro deve ser a entrada.',
      _ShiftStatus.working => 'Jornada em andamento com dispositivo validado.',
      _ShiftStatus.onBreak =>
        'Pausa aberta. O próximo registro recomendado é o retorno.',
    };
  }

  Color _statusColor() {
    return switch (_status) {
      _ShiftStatus.checkedOut => const Color(0xFF6B6254),
      _ShiftStatus.working => const Color(0xFF2F8F46),
      _ShiftStatus.onBreak => const Color(0xFF8C5D00),
    };
  }

  String _locationStatusLabel() {
    return switch (_locationState.status) {
      PunchLocationStatus.checking => 'Validando localização',
      PunchLocationStatus.ready =>
        _lastRegisteredLocation == null
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.84),
            ],
          ),
        ),
        child: Stack(
          children: [
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
      children: [
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
          children: [_buildSummaryPanel(), _buildWorkspace(isWide: false)],
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
          colors: [
            AppTheme.accent.withValues(alpha: 0.96),
            const Color(0xFFE28E00),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            'Ponto digital em tempo real.',
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Uma tela operacional para registrar entrada, pausa e saída com localização vinculada a cada batida.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.92),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          _buildSummaryStripe(
            label: 'Status',
            value: _statusLabel(),
            helper: _statusDescription(),
          ),
          const SizedBox(height: 16),
          _buildSummaryStripe(
            label: 'Funcionário',
            value: 'Marina Costa',
            helper: 'Operações · Unidade Paulista',
          ),
          const SizedBox(height: 16),
          _buildSummaryStripe(
            label: 'Última batida',
            value: _lastRecord == null
                ? '--:--'
                : _formatTime(_lastRecord!.timestamp),
            helper: _lastRecord?.title ?? 'Nenhum registro no dia',
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HighlightChip(label: _locationChipLabel()),
              const _HighlightChip(label: 'Dispositivo confiável'),
              const _HighlightChip(label: 'Jornada auditável'),
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
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bater ponto',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registre sua jornada com um fluxo direto, auditável e com coordenadas anexadas para validação operacional.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AdminEmployeesPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.groups_2_rounded),
                    label: const Text('Administrar equipe'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Voltar'),
                  ),
                ],
              ),
            ],
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

    return _SectionCard(
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
                    _StatusBadge(label: _statusLabel(), tone: _statusColor()),
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
    if (_status == _ShiftStatus.checkedOut) {
      return ElevatedButton.icon(
        onPressed: _isSubmittingPunch
            ? null
            : () {
                unawaited(_handlePunch(_PunchType.checkIn));
              },
        icon: const Icon(Icons.login_rounded),
        label: const Text('Registrar entrada'),
      );
    }

    if (_status == _ShiftStatus.working) {
      return ElevatedButton.icon(
        onPressed: _isSubmittingPunch
            ? null
            : () {
                unawaited(_handlePunch(_PunchType.breakStart));
              },
        icon: const Icon(Icons.pause_circle_outline_rounded),
        label: const Text('Iniciar pausa'),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isSubmittingPunch
          ? null
          : () {
              unawaited(_handlePunch(_PunchType.breakEnd));
            },
      icon: const Icon(Icons.play_circle_outline_rounded),
      label: const Text('Retomar jornada'),
    );
  }

  Widget _buildSecondaryActionButton() {
    if (_status == _ShiftStatus.checkedOut) {
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
              unawaited(_handlePunch(_PunchType.checkOut));
            },
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Registrar saída'),
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
          children: [
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Horas hoje',
                value: _formatDuration(_workedDuration()),
                helper: 'Tempo acumulado em jornada ativa',
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Pausa acumulada',
                value: _formatDuration(_breakDuration()),
                helper: 'Tempo total em intervalo no dia',
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Primeira entrada',
                value: _firstCheckIn == null
                    ? '--:--'
                    : _formatTime(_firstCheckIn!.timestamp),
                helper: 'Primeiro registro válido de hoje',
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                label: 'Último evento',
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

    return _SectionCard(
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

    return _SectionCard(
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
            label: 'Precisão',
            value: lastLocation == null
                ? '--'
                : _formatAccuracy(lastLocation.accuracyMeters),
          ),
          const _InfoFlag(label: 'Modo', value: 'Presencial rastreado'),
        ],
      ),
    );
  }

  Widget _buildSummaryStripe({
    required String label,
    required String value,
    required String helper,
  }) {
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
        children: [
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

enum _ShiftStatus { checkedOut, working, onBreak }

enum _PunchType { checkIn, breakStart, breakEnd, checkOut }

class _PunchRecord {
  const _PunchRecord({
    required this.type,
    required this.timestamp,
    required this.detail,
    this.location,
  });

  final _PunchType type;
  final DateTime timestamp;
  final String detail;
  final PunchLocationSnapshot? location;

  String get title {
    return switch (type) {
      _PunchType.checkIn => 'Entrada',
      _PunchType.breakStart => 'Pausa',
      _PunchType.breakEnd => 'Retorno',
      _PunchType.checkOut => 'Saída',
    };
  }

  IconData get icon {
    return switch (type) {
      _PunchType.checkIn => Icons.login_rounded,
      _PunchType.breakStart => Icons.pause_circle_outline_rounded,
      _PunchType.breakEnd => Icons.play_circle_outline_rounded,
      _PunchType.checkOut => Icons.logout_rounded,
    };
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
        children: [
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

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.record});

  final _PunchRecord record;

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
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
