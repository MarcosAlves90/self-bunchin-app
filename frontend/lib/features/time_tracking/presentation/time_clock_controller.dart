import 'dart:async';

import 'package:bunchin_flutter/contracts/punch.dart';
import 'package:bunchin_flutter/contracts/time_clock.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/time_tracking/application/punch_location_service.dart';
import 'package:flutter/foundation.dart';

class TimeClockController extends ChangeNotifier {
  TimeClockController({
    BunchinApi? api,
    PunchLocationService? punchLocationService,
  })  : _api = api ?? BunchinApi(),
        _punchLocationService = punchLocationService ?? const PunchLocationService();

  final BunchinApi _api;
  final PunchLocationService _punchLocationService;

  DateTime now = DateTime.now();
  List<PunchRecord> records = <PunchRecord>[];
  ShiftStatus status = ShiftStatus.checkedOut;
  PunchLocationResult locationState = const PunchLocationResult.checking();
  bool isSubmittingPunch = false;
  bool isLoadingState = true;
  String? loadError;
  String employeeName = 'Funcionario';
  String employeeUnit = '-';
  int todayWorkedMinutes = 0;
  int todayBreakMinutes = 0;

  Timer? _clockTimer;

  Future<void> start() async {
    now = DateTime.now();
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
      notifyListeners();
    });

    await prepareLocationAccess();
    await loadTimeClockState();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> loadTimeClockState() async {
    isLoadingState = true;
    loadError = null;
    notifyListeners();

    try {
      final state = await _api.getMyTimeClockState();

      employeeName = state.employee.name;
      employeeUnit = state.employee.unit;
      status = state.currentStatus;
      todayWorkedMinutes = state.todayWorkedMinutes;
      todayBreakMinutes = state.todayBreakMinutes;
      records = state.records;
      isLoadingState = false;
      notifyListeners();
    } on ApiException catch (error) {
      isLoadingState = false;
      loadError = error.message;
      notifyListeners();
    } catch (_) {
      isLoadingState = false;
      loadError = 'Não foi possível carregar o estado de ponto.';
      notifyListeners();
    }
  }

  Future<void> prepareLocationAccess() async {
    final result = await _punchLocationService.requestPermission();
    locationState = result;
    notifyListeners();
  }

  Future<String?> handlePunch(PunchType type) async {
    if (isSubmittingPunch) {
      return null;
    }

    isSubmittingPunch = true;
    notifyListeners();

    final locationResult = await _punchLocationService.captureForPunch();
    isSubmittingPunch = false;
    locationState = locationResult;
    notifyListeners();

    final location = locationResult.snapshot;
    if (location == null) {
      return locationResult.message;
    }

    try {
      final punch = await _api.createPunch(
        request: CreatePunchRequest(type: type, location: location),
      );
      await loadTimeClockState();
      return '${punch.title} registrado com sucesso.';
    } on ApiException catch (error) {
      return error.message;
    }
  }
}
