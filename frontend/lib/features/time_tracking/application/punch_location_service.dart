import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum PunchLocationStatus {
  checking,
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unsupported,
  error,
}

class PunchLocationSnapshot {
  const PunchLocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  factory PunchLocationSnapshot.fromPosition(Position position) {
    return PunchLocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      capturedAt: position.timestamp,
    );
  }

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
}

class PunchLocationResult {
  const PunchLocationResult._({
    required this.status,
    required this.message,
    this.snapshot,
  });

  const PunchLocationResult.checking()
    : this._(
        status: PunchLocationStatus.checking,
        message: 'Validando permissao de localizacao.',
      );

  const PunchLocationResult.ready({
    String message =
        'Permissao concedida. A localizacao sera anexada nas proximas batidas.',
    PunchLocationSnapshot? snapshot,
  }) : this._(
         status: PunchLocationStatus.ready,
         message: message,
         snapshot: snapshot,
       );

  const PunchLocationResult.serviceDisabled()
    : this._(
        status: PunchLocationStatus.serviceDisabled,
        message:
            'Os servicos de localizacao estao desativados. Ative-os para registrar o ponto.',
      );

  const PunchLocationResult.permissionDenied()
    : this._(
        status: PunchLocationStatus.permissionDenied,
        message:
            'A permissao de localizacao foi negada. Sem ela, a batida nao e registrada.',
      );

  const PunchLocationResult.permissionDeniedForever({
    String message =
        'A permissao de localizacao foi bloqueada. Reabilite o acesso nas configuracoes do dispositivo ou do navegador.',
  }) : this._(
         status: PunchLocationStatus.permissionDeniedForever,
         message: message,
       );

  const PunchLocationResult.unsupported({
    String message = 'Este ambiente nao oferece suporte a geolocalizacao.',
  }) : this._(status: PunchLocationStatus.unsupported, message: message);

  const PunchLocationResult.error({
    required String message,
    PunchLocationSnapshot? snapshot,
  }) : this._(
         status: PunchLocationStatus.error,
         message: message,
         snapshot: snapshot,
       );

  final PunchLocationStatus status;
  final String message;
  final PunchLocationSnapshot? snapshot;

  bool get isReady => status == PunchLocationStatus.ready;
}

class PunchLocationService {
  const PunchLocationService();

  Future<PunchLocationResult> requestPermission() async {
    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        return const PunchLocationResult.serviceDisabled();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }

      return _mapPermission(permission);
    } catch (error) {
      return _mapError(error);
    }
  }

  Future<PunchLocationResult> captureForPunch() async {
    final permissionResult = await requestPermission();
    if (!permissionResult.isReady) {
      return permissionResult;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings(),
      );

      return PunchLocationResult.ready(
        message: 'Localizacao validada e vinculada a batida.',
        snapshot: PunchLocationSnapshot.fromPosition(position),
      );
    } catch (error) {
      return _mapError(error);
    }
  }

  PunchLocationResult _mapPermission(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => const PunchLocationResult.ready(),
      LocationPermission.denied => const PunchLocationResult.permissionDenied(),
      LocationPermission.deniedForever =>
        const PunchLocationResult.permissionDeniedForever(),
      LocationPermission.unableToDetermine =>
        PunchLocationResult.permissionDeniedForever(
          message:
              'Nao foi possivel confirmar a permissao no navegador. Verifique o acesso ao local e tente novamente.',
        ),
    };
  }

  PunchLocationResult _mapError(Object error) {
    if (error is LocationServiceDisabledException) {
      return const PunchLocationResult.serviceDisabled();
    }

    if (error is PermissionDefinitionsNotFoundException) {
      return const PunchLocationResult.error(
        message:
            'A plataforma nao esta configurada para solicitar localizacao.',
      );
    }

    if (error is TimeoutException) {
      return const PunchLocationResult.error(
        message:
            'Tempo esgotado ao obter a localizacao. Tente novamente com melhor sinal.',
      );
    }

    if (error is UnsupportedError) {
      return PunchLocationResult.unsupported(
        message: kIsWeb
            ? 'No navegador, a geolocalizacao exige HTTPS ou localhost, alem da permissao do usuario.'
            : 'Este dispositivo nao oferece suporte a geolocalizacao.',
      );
    }

    return PunchLocationResult.error(
      message: kIsWeb
          ? 'Falha ao obter a localizacao. Verifique a permissao do navegador e se o site esta em HTTPS ou localhost.'
          : 'Falha ao obter a localizacao atual do dispositivo.',
    );
  }

  LocationSettings _locationSettings() {
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 12),
    );
  }
}
