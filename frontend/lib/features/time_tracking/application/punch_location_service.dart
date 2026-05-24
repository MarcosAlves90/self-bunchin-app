import 'dart:async';

import 'package:bunchin_flutter/contracts/location.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

export 'package:bunchin_flutter/contracts/location.dart';

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
              'Não foi possível confirmar a permissao no navegador. Verifique o acesso ao local e tente novamente.',
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
