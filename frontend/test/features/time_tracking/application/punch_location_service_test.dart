import 'package:bunchin_flutter/features/time_tracking/application/punch_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class _FakePunchLocationGateway extends PunchLocationGateway {
  _FakePunchLocationGateway({
    required this.servicesEnabled,
    required this.checkPermissionResult,
    required this.requestPermissionResult,
    required this.position,
  });

  final bool servicesEnabled;
  final LocationPermission checkPermissionResult;
  final LocationPermission requestPermissionResult;
  final Position position;

  int checkPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int getCurrentPositionCalls = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => servicesEnabled;

  @override
  Future<LocationPermission> checkPermission() async {
    checkPermissionCalls += 1;
    return checkPermissionResult;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCalls += 1;
    return requestPermissionResult;
  }

  @override
  Future<Position> getCurrentPosition({
    required LocationSettings locationSettings,
  }) async {
    getCurrentPositionCalls += 1;
    return position;
  }
}

Position _position() {
  return Position(
    latitude: -23.55052,
    longitude: -46.63331,
    timestamp: DateTime.utc(2026, 5, 24, 13, 30),
    accuracy: 7.5,
    altitude: 760.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );
}

void main() {
  test(
    'requestPermission falls back to current position when permission APIs lie',
    () async {
      final gateway = _FakePunchLocationGateway(
        servicesEnabled: true,
        checkPermissionResult: LocationPermission.denied,
        requestPermissionResult: LocationPermission.denied,
        position: _position(),
      );

      final service = PunchLocationService(gateway: gateway);
      final result = await service.requestPermission();

      expect(result.isReady, isTrue);
      expect(result.snapshot, isNotNull);
      expect(result.snapshot?.latitude, closeTo(-23.55052, 0.00001));
      expect(gateway.checkPermissionCalls, 1);
      expect(gateway.requestPermissionCalls, 1);
      expect(gateway.getCurrentPositionCalls, 1);
    },
  );
}
