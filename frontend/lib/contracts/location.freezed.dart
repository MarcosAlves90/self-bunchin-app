// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PunchLocationSnapshot {
  double get latitude;
  double get longitude;
  double get accuracyMeters;
  DateTime get capturedAt;

  /// Create a copy of PunchLocationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PunchLocationSnapshotCopyWith<PunchLocationSnapshot> get copyWith =>
      _$PunchLocationSnapshotCopyWithImpl<PunchLocationSnapshot>(
          this as PunchLocationSnapshot, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PunchLocationSnapshot &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracyMeters, accuracyMeters) ||
                other.accuracyMeters == accuracyMeters) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, latitude, longitude, accuracyMeters, capturedAt);

  @override
  String toString() {
    return 'PunchLocationSnapshot(latitude: $latitude, longitude: $longitude, accuracyMeters: $accuracyMeters, capturedAt: $capturedAt)';
  }
}

/// @nodoc
abstract mixin class $PunchLocationSnapshotCopyWith<$Res> {
  factory $PunchLocationSnapshotCopyWith(PunchLocationSnapshot value,
          $Res Function(PunchLocationSnapshot) _then) =
      _$PunchLocationSnapshotCopyWithImpl;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double accuracyMeters,
      DateTime capturedAt});
}

/// @nodoc
class _$PunchLocationSnapshotCopyWithImpl<$Res>
    implements $PunchLocationSnapshotCopyWith<$Res> {
  _$PunchLocationSnapshotCopyWithImpl(this._self, this._then);

  final PunchLocationSnapshot _self;
  final $Res Function(PunchLocationSnapshot) _then;

  /// Create a copy of PunchLocationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracyMeters = null,
    Object? capturedAt = null,
  }) {
    return _then(_self.copyWith(
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracyMeters: null == accuracyMeters
          ? _self.accuracyMeters
          : accuracyMeters // ignore: cast_nullable_to_non_nullable
              as double,
      capturedAt: null == capturedAt
          ? _self.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [PunchLocationSnapshot].
extension PunchLocationSnapshotPatterns on PunchLocationSnapshot {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PunchLocationSnapshot value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationSnapshot() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PunchLocationSnapshot value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PunchLocationSnapshot():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PunchLocationSnapshot value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PunchLocationSnapshot() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(double latitude, double longitude, double accuracyMeters,
            DateTime capturedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationSnapshot() when $default != null:
        return $default(_that.latitude, _that.longitude, _that.accuracyMeters,
            _that.capturedAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(double latitude, double longitude, double accuracyMeters,
            DateTime capturedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PunchLocationSnapshot():
        return $default(_that.latitude, _that.longitude, _that.accuracyMeters,
            _that.capturedAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(double latitude, double longitude, double accuracyMeters,
            DateTime capturedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PunchLocationSnapshot() when $default != null:
        return $default(_that.latitude, _that.longitude, _that.accuracyMeters,
            _that.capturedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PunchLocationSnapshot extends PunchLocationSnapshot {
  const _PunchLocationSnapshot(
      {required this.latitude,
      required this.longitude,
      required this.accuracyMeters,
      required this.capturedAt})
      : super._();

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double accuracyMeters;
  @override
  final DateTime capturedAt;

  /// Create a copy of PunchLocationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PunchLocationSnapshotCopyWith<_PunchLocationSnapshot> get copyWith =>
      __$PunchLocationSnapshotCopyWithImpl<_PunchLocationSnapshot>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PunchLocationSnapshot &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracyMeters, accuracyMeters) ||
                other.accuracyMeters == accuracyMeters) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, latitude, longitude, accuracyMeters, capturedAt);

  @override
  String toString() {
    return 'PunchLocationSnapshot(latitude: $latitude, longitude: $longitude, accuracyMeters: $accuracyMeters, capturedAt: $capturedAt)';
  }
}

/// @nodoc
abstract mixin class _$PunchLocationSnapshotCopyWith<$Res>
    implements $PunchLocationSnapshotCopyWith<$Res> {
  factory _$PunchLocationSnapshotCopyWith(_PunchLocationSnapshot value,
          $Res Function(_PunchLocationSnapshot) _then) =
      __$PunchLocationSnapshotCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double accuracyMeters,
      DateTime capturedAt});
}

/// @nodoc
class __$PunchLocationSnapshotCopyWithImpl<$Res>
    implements _$PunchLocationSnapshotCopyWith<$Res> {
  __$PunchLocationSnapshotCopyWithImpl(this._self, this._then);

  final _PunchLocationSnapshot _self;
  final $Res Function(_PunchLocationSnapshot) _then;

  /// Create a copy of PunchLocationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracyMeters = null,
    Object? capturedAt = null,
  }) {
    return _then(_PunchLocationSnapshot(
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracyMeters: null == accuracyMeters
          ? _self.accuracyMeters
          : accuracyMeters // ignore: cast_nullable_to_non_nullable
              as double,
      capturedAt: null == capturedAt
          ? _self.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$PunchLocationResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PunchLocationResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PunchLocationResult()';
  }
}

/// @nodoc
class $PunchLocationResultCopyWith<$Res> {
  $PunchLocationResultCopyWith(
      PunchLocationResult _, $Res Function(PunchLocationResult) __);
}

/// Adds pattern-matching-related methods to [PunchLocationResult].
extension PunchLocationResultPatterns on PunchLocationResult {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PunchLocationChecking value)? checking,
    TResult Function(_PunchLocationReady value)? ready,
    TResult Function(_PunchLocationServiceDisabled value)? serviceDisabled,
    TResult Function(_PunchLocationPermissionDenied value)? permissionDenied,
    TResult Function(_PunchLocationPermissionDeniedForever value)?
        permissionDeniedForever,
    TResult Function(_PunchLocationUnsupported value)? unsupported,
    TResult Function(_PunchLocationError value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationChecking() when checking != null:
        return checking(_that);
      case _PunchLocationReady() when ready != null:
        return ready(_that);
      case _PunchLocationServiceDisabled() when serviceDisabled != null:
        return serviceDisabled(_that);
      case _PunchLocationPermissionDenied() when permissionDenied != null:
        return permissionDenied(_that);
      case _PunchLocationPermissionDeniedForever()
          when permissionDeniedForever != null:
        return permissionDeniedForever(_that);
      case _PunchLocationUnsupported() when unsupported != null:
        return unsupported(_that);
      case _PunchLocationError() when error != null:
        return error(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PunchLocationChecking value) checking,
    required TResult Function(_PunchLocationReady value) ready,
    required TResult Function(_PunchLocationServiceDisabled value)
        serviceDisabled,
    required TResult Function(_PunchLocationPermissionDenied value)
        permissionDenied,
    required TResult Function(_PunchLocationPermissionDeniedForever value)
        permissionDeniedForever,
    required TResult Function(_PunchLocationUnsupported value) unsupported,
    required TResult Function(_PunchLocationError value) error,
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationChecking():
        return checking(_that);
      case _PunchLocationReady():
        return ready(_that);
      case _PunchLocationServiceDisabled():
        return serviceDisabled(_that);
      case _PunchLocationPermissionDenied():
        return permissionDenied(_that);
      case _PunchLocationPermissionDeniedForever():
        return permissionDeniedForever(_that);
      case _PunchLocationUnsupported():
        return unsupported(_that);
      case _PunchLocationError():
        return error(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PunchLocationChecking value)? checking,
    TResult? Function(_PunchLocationReady value)? ready,
    TResult? Function(_PunchLocationServiceDisabled value)? serviceDisabled,
    TResult? Function(_PunchLocationPermissionDenied value)? permissionDenied,
    TResult? Function(_PunchLocationPermissionDeniedForever value)?
        permissionDeniedForever,
    TResult? Function(_PunchLocationUnsupported value)? unsupported,
    TResult? Function(_PunchLocationError value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationChecking() when checking != null:
        return checking(_that);
      case _PunchLocationReady() when ready != null:
        return ready(_that);
      case _PunchLocationServiceDisabled() when serviceDisabled != null:
        return serviceDisabled(_that);
      case _PunchLocationPermissionDenied() when permissionDenied != null:
        return permissionDenied(_that);
      case _PunchLocationPermissionDeniedForever()
          when permissionDeniedForever != null:
        return permissionDeniedForever(_that);
      case _PunchLocationUnsupported() when unsupported != null:
        return unsupported(_that);
      case _PunchLocationError() when error != null:
        return error(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checking,
    TResult Function(String message, PunchLocationSnapshot? snapshot)? ready,
    TResult Function()? serviceDisabled,
    TResult Function()? permissionDenied,
    TResult Function(String message)? permissionDeniedForever,
    TResult Function(String message)? unsupported,
    TResult Function(String message, PunchLocationSnapshot? snapshot)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationChecking() when checking != null:
        return checking();
      case _PunchLocationReady() when ready != null:
        return ready(_that.message, _that.snapshot);
      case _PunchLocationServiceDisabled() when serviceDisabled != null:
        return serviceDisabled();
      case _PunchLocationPermissionDenied() when permissionDenied != null:
        return permissionDenied();
      case _PunchLocationPermissionDeniedForever()
          when permissionDeniedForever != null:
        return permissionDeniedForever(_that.message);
      case _PunchLocationUnsupported() when unsupported != null:
        return unsupported(_that.message);
      case _PunchLocationError() when error != null:
        return error(_that.message, _that.snapshot);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checking,
    required TResult Function(String message, PunchLocationSnapshot? snapshot)
        ready,
    required TResult Function() serviceDisabled,
    required TResult Function() permissionDenied,
    required TResult Function(String message) permissionDeniedForever,
    required TResult Function(String message) unsupported,
    required TResult Function(String message, PunchLocationSnapshot? snapshot)
        error,
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationChecking():
        return checking();
      case _PunchLocationReady():
        return ready(_that.message, _that.snapshot);
      case _PunchLocationServiceDisabled():
        return serviceDisabled();
      case _PunchLocationPermissionDenied():
        return permissionDenied();
      case _PunchLocationPermissionDeniedForever():
        return permissionDeniedForever(_that.message);
      case _PunchLocationUnsupported():
        return unsupported(_that.message);
      case _PunchLocationError():
        return error(_that.message, _that.snapshot);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checking,
    TResult? Function(String message, PunchLocationSnapshot? snapshot)? ready,
    TResult? Function()? serviceDisabled,
    TResult? Function()? permissionDenied,
    TResult? Function(String message)? permissionDeniedForever,
    TResult? Function(String message)? unsupported,
    TResult? Function(String message, PunchLocationSnapshot? snapshot)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _PunchLocationChecking() when checking != null:
        return checking();
      case _PunchLocationReady() when ready != null:
        return ready(_that.message, _that.snapshot);
      case _PunchLocationServiceDisabled() when serviceDisabled != null:
        return serviceDisabled();
      case _PunchLocationPermissionDenied() when permissionDenied != null:
        return permissionDenied();
      case _PunchLocationPermissionDeniedForever()
          when permissionDeniedForever != null:
        return permissionDeniedForever(_that.message);
      case _PunchLocationUnsupported() when unsupported != null:
        return unsupported(_that.message);
      case _PunchLocationError() when error != null:
        return error(_that.message, _that.snapshot);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PunchLocationChecking extends PunchLocationResult {
  const _PunchLocationChecking() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _PunchLocationChecking);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PunchLocationResult.checking()';
  }
}

/// @nodoc

class _PunchLocationReady extends PunchLocationResult {
  const _PunchLocationReady(
      {this.message =
          'Permissao concedida. A localizacao sera anexada nas proximas batidas.',
      this.snapshot})
      : super._();

  @JsonKey()
  final String message;
  final PunchLocationSnapshot? snapshot;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PunchLocationReadyCopyWith<_PunchLocationReady> get copyWith =>
      __$PunchLocationReadyCopyWithImpl<_PunchLocationReady>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PunchLocationReady &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.snapshot, snapshot) ||
                other.snapshot == snapshot));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, snapshot);

  @override
  String toString() {
    return 'PunchLocationResult.ready(message: $message, snapshot: $snapshot)';
  }
}

/// @nodoc
abstract mixin class _$PunchLocationReadyCopyWith<$Res>
    implements $PunchLocationResultCopyWith<$Res> {
  factory _$PunchLocationReadyCopyWith(
          _PunchLocationReady value, $Res Function(_PunchLocationReady) _then) =
      __$PunchLocationReadyCopyWithImpl;
  @useResult
  $Res call({String message, PunchLocationSnapshot? snapshot});

  $PunchLocationSnapshotCopyWith<$Res>? get snapshot;
}

/// @nodoc
class __$PunchLocationReadyCopyWithImpl<$Res>
    implements _$PunchLocationReadyCopyWith<$Res> {
  __$PunchLocationReadyCopyWithImpl(this._self, this._then);

  final _PunchLocationReady _self;
  final $Res Function(_PunchLocationReady) _then;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? snapshot = freezed,
  }) {
    return _then(_PunchLocationReady(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      snapshot: freezed == snapshot
          ? _self.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as PunchLocationSnapshot?,
    ));
  }

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PunchLocationSnapshotCopyWith<$Res>? get snapshot {
    if (_self.snapshot == null) {
      return null;
    }

    return $PunchLocationSnapshotCopyWith<$Res>(_self.snapshot!, (value) {
      return _then(_self.copyWith(snapshot: value));
    });
  }
}

/// @nodoc

class _PunchLocationServiceDisabled extends PunchLocationResult {
  const _PunchLocationServiceDisabled() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PunchLocationServiceDisabled);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PunchLocationResult.serviceDisabled()';
  }
}

/// @nodoc

class _PunchLocationPermissionDenied extends PunchLocationResult {
  const _PunchLocationPermissionDenied() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PunchLocationPermissionDenied);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PunchLocationResult.permissionDenied()';
  }
}

/// @nodoc

class _PunchLocationPermissionDeniedForever extends PunchLocationResult {
  const _PunchLocationPermissionDeniedForever(
      {this.message =
          'A permissao de localizacao foi bloqueada. Reabilite o acesso nas configuracoes do dispositivo ou do navegador.'})
      : super._();

  @JsonKey()
  final String message;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PunchLocationPermissionDeniedForeverCopyWith<
          _PunchLocationPermissionDeniedForever>
      get copyWith => __$PunchLocationPermissionDeniedForeverCopyWithImpl<
          _PunchLocationPermissionDeniedForever>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PunchLocationPermissionDeniedForever &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'PunchLocationResult.permissionDeniedForever(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$PunchLocationPermissionDeniedForeverCopyWith<$Res>
    implements $PunchLocationResultCopyWith<$Res> {
  factory _$PunchLocationPermissionDeniedForeverCopyWith(
          _PunchLocationPermissionDeniedForever value,
          $Res Function(_PunchLocationPermissionDeniedForever) _then) =
      __$PunchLocationPermissionDeniedForeverCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$PunchLocationPermissionDeniedForeverCopyWithImpl<$Res>
    implements _$PunchLocationPermissionDeniedForeverCopyWith<$Res> {
  __$PunchLocationPermissionDeniedForeverCopyWithImpl(this._self, this._then);

  final _PunchLocationPermissionDeniedForever _self;
  final $Res Function(_PunchLocationPermissionDeniedForever) _then;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_PunchLocationPermissionDeniedForever(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _PunchLocationUnsupported extends PunchLocationResult {
  const _PunchLocationUnsupported(
      {this.message = 'Este ambiente nao oferece suporte a geolocalizacao.'})
      : super._();

  @JsonKey()
  final String message;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PunchLocationUnsupportedCopyWith<_PunchLocationUnsupported> get copyWith =>
      __$PunchLocationUnsupportedCopyWithImpl<_PunchLocationUnsupported>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PunchLocationUnsupported &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'PunchLocationResult.unsupported(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$PunchLocationUnsupportedCopyWith<$Res>
    implements $PunchLocationResultCopyWith<$Res> {
  factory _$PunchLocationUnsupportedCopyWith(_PunchLocationUnsupported value,
          $Res Function(_PunchLocationUnsupported) _then) =
      __$PunchLocationUnsupportedCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$PunchLocationUnsupportedCopyWithImpl<$Res>
    implements _$PunchLocationUnsupportedCopyWith<$Res> {
  __$PunchLocationUnsupportedCopyWithImpl(this._self, this._then);

  final _PunchLocationUnsupported _self;
  final $Res Function(_PunchLocationUnsupported) _then;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_PunchLocationUnsupported(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _PunchLocationError extends PunchLocationResult {
  const _PunchLocationError({required this.message, this.snapshot}) : super._();

  final String message;
  final PunchLocationSnapshot? snapshot;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PunchLocationErrorCopyWith<_PunchLocationError> get copyWith =>
      __$PunchLocationErrorCopyWithImpl<_PunchLocationError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PunchLocationError &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.snapshot, snapshot) ||
                other.snapshot == snapshot));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, snapshot);

  @override
  String toString() {
    return 'PunchLocationResult.error(message: $message, snapshot: $snapshot)';
  }
}

/// @nodoc
abstract mixin class _$PunchLocationErrorCopyWith<$Res>
    implements $PunchLocationResultCopyWith<$Res> {
  factory _$PunchLocationErrorCopyWith(
          _PunchLocationError value, $Res Function(_PunchLocationError) _then) =
      __$PunchLocationErrorCopyWithImpl;
  @useResult
  $Res call({String message, PunchLocationSnapshot? snapshot});

  $PunchLocationSnapshotCopyWith<$Res>? get snapshot;
}

/// @nodoc
class __$PunchLocationErrorCopyWithImpl<$Res>
    implements _$PunchLocationErrorCopyWith<$Res> {
  __$PunchLocationErrorCopyWithImpl(this._self, this._then);

  final _PunchLocationError _self;
  final $Res Function(_PunchLocationError) _then;

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? snapshot = freezed,
  }) {
    return _then(_PunchLocationError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      snapshot: freezed == snapshot
          ? _self.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as PunchLocationSnapshot?,
    ));
  }

  /// Create a copy of PunchLocationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PunchLocationSnapshotCopyWith<$Res>? get snapshot {
    if (_self.snapshot == null) {
      return null;
    }

    return $PunchLocationSnapshotCopyWith<$Res>(_self.snapshot!, (value) {
      return _then(_self.copyWith(snapshot: value));
    });
  }
}

// dart format on
