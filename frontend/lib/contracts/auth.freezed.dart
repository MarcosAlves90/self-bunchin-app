// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginCredentials {
  String get email;
  String get password;
  bool get keepConnected;

  /// Create a copy of LoginCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LoginCredentialsCopyWith<LoginCredentials> get copyWith =>
      _$LoginCredentialsCopyWithImpl<LoginCredentials>(
          this as LoginCredentials, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LoginCredentials &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.keepConnected, keepConnected) ||
                other.keepConnected == keepConnected));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password, keepConnected);

  @override
  String toString() {
    return 'LoginCredentials(email: $email, password: $password, keepConnected: $keepConnected)';
  }
}

/// @nodoc
abstract mixin class $LoginCredentialsCopyWith<$Res> {
  factory $LoginCredentialsCopyWith(
          LoginCredentials value, $Res Function(LoginCredentials) _then) =
      _$LoginCredentialsCopyWithImpl;
  @useResult
  $Res call({String email, String password, bool keepConnected});
}

/// @nodoc
class _$LoginCredentialsCopyWithImpl<$Res>
    implements $LoginCredentialsCopyWith<$Res> {
  _$LoginCredentialsCopyWithImpl(this._self, this._then);

  final LoginCredentials _self;
  final $Res Function(LoginCredentials) _then;

  /// Create a copy of LoginCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? keepConnected = null,
  }) {
    return _then(_self.copyWith(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      keepConnected: null == keepConnected
          ? _self.keepConnected
          : keepConnected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [LoginCredentials].
extension LoginCredentialsPatterns on LoginCredentials {
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
    TResult Function(_LoginCredentials value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoginCredentials() when $default != null:
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
    TResult Function(_LoginCredentials value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginCredentials():
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
    TResult? Function(_LoginCredentials value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginCredentials() when $default != null:
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
    TResult Function(String email, String password, bool keepConnected)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoginCredentials() when $default != null:
        return $default(_that.email, _that.password, _that.keepConnected);
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
    TResult Function(String email, String password, bool keepConnected)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginCredentials():
        return $default(_that.email, _that.password, _that.keepConnected);
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
    TResult? Function(String email, String password, bool keepConnected)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginCredentials() when $default != null:
        return $default(_that.email, _that.password, _that.keepConnected);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LoginCredentials extends LoginCredentials {
  const _LoginCredentials(
      {required this.email, required this.password, this.keepConnected = true})
      : super._();

  @override
  final String email;
  @override
  final String password;
  @override
  @JsonKey()
  final bool keepConnected;

  /// Create a copy of LoginCredentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoginCredentialsCopyWith<_LoginCredentials> get copyWith =>
      __$LoginCredentialsCopyWithImpl<_LoginCredentials>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoginCredentials &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.keepConnected, keepConnected) ||
                other.keepConnected == keepConnected));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password, keepConnected);

  @override
  String toString() {
    return 'LoginCredentials(email: $email, password: $password, keepConnected: $keepConnected)';
  }
}

/// @nodoc
abstract mixin class _$LoginCredentialsCopyWith<$Res>
    implements $LoginCredentialsCopyWith<$Res> {
  factory _$LoginCredentialsCopyWith(
          _LoginCredentials value, $Res Function(_LoginCredentials) _then) =
      __$LoginCredentialsCopyWithImpl;
  @override
  @useResult
  $Res call({String email, String password, bool keepConnected});
}

/// @nodoc
class __$LoginCredentialsCopyWithImpl<$Res>
    implements _$LoginCredentialsCopyWith<$Res> {
  __$LoginCredentialsCopyWithImpl(this._self, this._then);

  final _LoginCredentials _self;
  final $Res Function(_LoginCredentials) _then;

  /// Create a copy of LoginCredentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? keepConnected = null,
  }) {
    return _then(_LoginCredentials(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      keepConnected: null == keepConnected
          ? _self.keepConnected
          : keepConnected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$CompanyRegistrationDraft {
  String get companyName;
  String get tradeName;
  String get cnpj;
  String get email;
  String get phone;
  String get password;
  bool get acceptTerms;

  /// Create a copy of CompanyRegistrationDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CompanyRegistrationDraftCopyWith<CompanyRegistrationDraft> get copyWith =>
      _$CompanyRegistrationDraftCopyWithImpl<CompanyRegistrationDraft>(
          this as CompanyRegistrationDraft, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompanyRegistrationDraft &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.tradeName, tradeName) ||
                other.tradeName == tradeName) &&
            (identical(other.cnpj, cnpj) || other.cnpj == cnpj) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.acceptTerms, acceptTerms) ||
                other.acceptTerms == acceptTerms));
  }

  @override
  int get hashCode => Object.hash(runtimeType, companyName, tradeName, cnpj,
      email, phone, password, acceptTerms);

  @override
  String toString() {
    return 'CompanyRegistrationDraft(companyName: $companyName, tradeName: $tradeName, cnpj: $cnpj, email: $email, phone: $phone, password: $password, acceptTerms: $acceptTerms)';
  }
}

/// @nodoc
abstract mixin class $CompanyRegistrationDraftCopyWith<$Res> {
  factory $CompanyRegistrationDraftCopyWith(CompanyRegistrationDraft value,
          $Res Function(CompanyRegistrationDraft) _then) =
      _$CompanyRegistrationDraftCopyWithImpl;
  @useResult
  $Res call(
      {String companyName,
      String tradeName,
      String cnpj,
      String email,
      String phone,
      String password,
      bool acceptTerms});
}

/// @nodoc
class _$CompanyRegistrationDraftCopyWithImpl<$Res>
    implements $CompanyRegistrationDraftCopyWith<$Res> {
  _$CompanyRegistrationDraftCopyWithImpl(this._self, this._then);

  final CompanyRegistrationDraft _self;
  final $Res Function(CompanyRegistrationDraft) _then;

  /// Create a copy of CompanyRegistrationDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = null,
    Object? tradeName = null,
    Object? cnpj = null,
    Object? email = null,
    Object? phone = null,
    Object? password = null,
    Object? acceptTerms = null,
  }) {
    return _then(_self.copyWith(
      companyName: null == companyName
          ? _self.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String,
      tradeName: null == tradeName
          ? _self.tradeName
          : tradeName // ignore: cast_nullable_to_non_nullable
              as String,
      cnpj: null == cnpj
          ? _self.cnpj
          : cnpj // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      acceptTerms: null == acceptTerms
          ? _self.acceptTerms
          : acceptTerms // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [CompanyRegistrationDraft].
extension CompanyRegistrationDraftPatterns on CompanyRegistrationDraft {
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
    TResult Function(_CompanyRegistrationDraft value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompanyRegistrationDraft() when $default != null:
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
    TResult Function(_CompanyRegistrationDraft value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompanyRegistrationDraft():
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
    TResult? Function(_CompanyRegistrationDraft value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompanyRegistrationDraft() when $default != null:
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
    TResult Function(String companyName, String tradeName, String cnpj,
            String email, String phone, String password, bool acceptTerms)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompanyRegistrationDraft() when $default != null:
        return $default(_that.companyName, _that.tradeName, _that.cnpj,
            _that.email, _that.phone, _that.password, _that.acceptTerms);
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
    TResult Function(String companyName, String tradeName, String cnpj,
            String email, String phone, String password, bool acceptTerms)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompanyRegistrationDraft():
        return $default(_that.companyName, _that.tradeName, _that.cnpj,
            _that.email, _that.phone, _that.password, _that.acceptTerms);
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
    TResult? Function(String companyName, String tradeName, String cnpj,
            String email, String phone, String password, bool acceptTerms)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompanyRegistrationDraft() when $default != null:
        return $default(_that.companyName, _that.tradeName, _that.cnpj,
            _that.email, _that.phone, _that.password, _that.acceptTerms);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CompanyRegistrationDraft extends CompanyRegistrationDraft {
  const _CompanyRegistrationDraft(
      {required this.companyName,
      required this.tradeName,
      required this.cnpj,
      required this.email,
      required this.phone,
      required this.password,
      required this.acceptTerms})
      : super._();

  @override
  final String companyName;
  @override
  final String tradeName;
  @override
  final String cnpj;
  @override
  final String email;
  @override
  final String phone;
  @override
  final String password;
  @override
  final bool acceptTerms;

  /// Create a copy of CompanyRegistrationDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CompanyRegistrationDraftCopyWith<_CompanyRegistrationDraft> get copyWith =>
      __$CompanyRegistrationDraftCopyWithImpl<_CompanyRegistrationDraft>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CompanyRegistrationDraft &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.tradeName, tradeName) ||
                other.tradeName == tradeName) &&
            (identical(other.cnpj, cnpj) || other.cnpj == cnpj) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.acceptTerms, acceptTerms) ||
                other.acceptTerms == acceptTerms));
  }

  @override
  int get hashCode => Object.hash(runtimeType, companyName, tradeName, cnpj,
      email, phone, password, acceptTerms);

  @override
  String toString() {
    return 'CompanyRegistrationDraft(companyName: $companyName, tradeName: $tradeName, cnpj: $cnpj, email: $email, phone: $phone, password: $password, acceptTerms: $acceptTerms)';
  }
}

/// @nodoc
abstract mixin class _$CompanyRegistrationDraftCopyWith<$Res>
    implements $CompanyRegistrationDraftCopyWith<$Res> {
  factory _$CompanyRegistrationDraftCopyWith(_CompanyRegistrationDraft value,
          $Res Function(_CompanyRegistrationDraft) _then) =
      __$CompanyRegistrationDraftCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String companyName,
      String tradeName,
      String cnpj,
      String email,
      String phone,
      String password,
      bool acceptTerms});
}

/// @nodoc
class __$CompanyRegistrationDraftCopyWithImpl<$Res>
    implements _$CompanyRegistrationDraftCopyWith<$Res> {
  __$CompanyRegistrationDraftCopyWithImpl(this._self, this._then);

  final _CompanyRegistrationDraft _self;
  final $Res Function(_CompanyRegistrationDraft) _then;

  /// Create a copy of CompanyRegistrationDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? companyName = null,
    Object? tradeName = null,
    Object? cnpj = null,
    Object? email = null,
    Object? phone = null,
    Object? password = null,
    Object? acceptTerms = null,
  }) {
    return _then(_CompanyRegistrationDraft(
      companyName: null == companyName
          ? _self.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String,
      tradeName: null == tradeName
          ? _self.tradeName
          : tradeName // ignore: cast_nullable_to_non_nullable
              as String,
      cnpj: null == cnpj
          ? _self.cnpj
          : cnpj // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      acceptTerms: null == acceptTerms
          ? _self.acceptTerms
          : acceptTerms // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$AuthCompanySummary {
  String get id;
  String get legalName;
  String get tradeName;
  String get cnpjMasked;
  String get emailMasked;
  String get phoneMasked;

  /// Create a copy of AuthCompanySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthCompanySummaryCopyWith<AuthCompanySummary> get copyWith =>
      _$AuthCompanySummaryCopyWithImpl<AuthCompanySummary>(
          this as AuthCompanySummary, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthCompanySummary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.legalName, legalName) ||
                other.legalName == legalName) &&
            (identical(other.tradeName, tradeName) ||
                other.tradeName == tradeName) &&
            (identical(other.cnpjMasked, cnpjMasked) ||
                other.cnpjMasked == cnpjMasked) &&
            (identical(other.emailMasked, emailMasked) ||
                other.emailMasked == emailMasked) &&
            (identical(other.phoneMasked, phoneMasked) ||
                other.phoneMasked == phoneMasked));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, legalName, tradeName,
      cnpjMasked, emailMasked, phoneMasked);

  @override
  String toString() {
    return 'AuthCompanySummary(id: $id, legalName: $legalName, tradeName: $tradeName, cnpjMasked: $cnpjMasked, emailMasked: $emailMasked, phoneMasked: $phoneMasked)';
  }
}

/// @nodoc
abstract mixin class $AuthCompanySummaryCopyWith<$Res> {
  factory $AuthCompanySummaryCopyWith(
          AuthCompanySummary value, $Res Function(AuthCompanySummary) _then) =
      _$AuthCompanySummaryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String legalName,
      String tradeName,
      String cnpjMasked,
      String emailMasked,
      String phoneMasked});
}

/// @nodoc
class _$AuthCompanySummaryCopyWithImpl<$Res>
    implements $AuthCompanySummaryCopyWith<$Res> {
  _$AuthCompanySummaryCopyWithImpl(this._self, this._then);

  final AuthCompanySummary _self;
  final $Res Function(AuthCompanySummary) _then;

  /// Create a copy of AuthCompanySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? legalName = null,
    Object? tradeName = null,
    Object? cnpjMasked = null,
    Object? emailMasked = null,
    Object? phoneMasked = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      legalName: null == legalName
          ? _self.legalName
          : legalName // ignore: cast_nullable_to_non_nullable
              as String,
      tradeName: null == tradeName
          ? _self.tradeName
          : tradeName // ignore: cast_nullable_to_non_nullable
              as String,
      cnpjMasked: null == cnpjMasked
          ? _self.cnpjMasked
          : cnpjMasked // ignore: cast_nullable_to_non_nullable
              as String,
      emailMasked: null == emailMasked
          ? _self.emailMasked
          : emailMasked // ignore: cast_nullable_to_non_nullable
              as String,
      phoneMasked: null == phoneMasked
          ? _self.phoneMasked
          : phoneMasked // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AuthCompanySummary].
extension AuthCompanySummaryPatterns on AuthCompanySummary {
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
    TResult Function(_AuthCompanySummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthCompanySummary() when $default != null:
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
    TResult Function(_AuthCompanySummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthCompanySummary():
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
    TResult? Function(_AuthCompanySummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthCompanySummary() when $default != null:
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
    TResult Function(String id, String legalName, String tradeName,
            String cnpjMasked, String emailMasked, String phoneMasked)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthCompanySummary() when $default != null:
        return $default(_that.id, _that.legalName, _that.tradeName,
            _that.cnpjMasked, _that.emailMasked, _that.phoneMasked);
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
    TResult Function(String id, String legalName, String tradeName,
            String cnpjMasked, String emailMasked, String phoneMasked)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthCompanySummary():
        return $default(_that.id, _that.legalName, _that.tradeName,
            _that.cnpjMasked, _that.emailMasked, _that.phoneMasked);
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
    TResult? Function(String id, String legalName, String tradeName,
            String cnpjMasked, String emailMasked, String phoneMasked)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthCompanySummary() when $default != null:
        return $default(_that.id, _that.legalName, _that.tradeName,
            _that.cnpjMasked, _that.emailMasked, _that.phoneMasked);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuthCompanySummary extends AuthCompanySummary {
  const _AuthCompanySummary(
      {required this.id,
      required this.legalName,
      required this.tradeName,
      required this.cnpjMasked,
      required this.emailMasked,
      required this.phoneMasked})
      : super._();

  @override
  final String id;
  @override
  final String legalName;
  @override
  final String tradeName;
  @override
  final String cnpjMasked;
  @override
  final String emailMasked;
  @override
  final String phoneMasked;

  /// Create a copy of AuthCompanySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthCompanySummaryCopyWith<_AuthCompanySummary> get copyWith =>
      __$AuthCompanySummaryCopyWithImpl<_AuthCompanySummary>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthCompanySummary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.legalName, legalName) ||
                other.legalName == legalName) &&
            (identical(other.tradeName, tradeName) ||
                other.tradeName == tradeName) &&
            (identical(other.cnpjMasked, cnpjMasked) ||
                other.cnpjMasked == cnpjMasked) &&
            (identical(other.emailMasked, emailMasked) ||
                other.emailMasked == emailMasked) &&
            (identical(other.phoneMasked, phoneMasked) ||
                other.phoneMasked == phoneMasked));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, legalName, tradeName,
      cnpjMasked, emailMasked, phoneMasked);

  @override
  String toString() {
    return 'AuthCompanySummary(id: $id, legalName: $legalName, tradeName: $tradeName, cnpjMasked: $cnpjMasked, emailMasked: $emailMasked, phoneMasked: $phoneMasked)';
  }
}

/// @nodoc
abstract mixin class _$AuthCompanySummaryCopyWith<$Res>
    implements $AuthCompanySummaryCopyWith<$Res> {
  factory _$AuthCompanySummaryCopyWith(
          _AuthCompanySummary value, $Res Function(_AuthCompanySummary) _then) =
      __$AuthCompanySummaryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String legalName,
      String tradeName,
      String cnpjMasked,
      String emailMasked,
      String phoneMasked});
}

/// @nodoc
class __$AuthCompanySummaryCopyWithImpl<$Res>
    implements _$AuthCompanySummaryCopyWith<$Res> {
  __$AuthCompanySummaryCopyWithImpl(this._self, this._then);

  final _AuthCompanySummary _self;
  final $Res Function(_AuthCompanySummary) _then;

  /// Create a copy of AuthCompanySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? legalName = null,
    Object? tradeName = null,
    Object? cnpjMasked = null,
    Object? emailMasked = null,
    Object? phoneMasked = null,
  }) {
    return _then(_AuthCompanySummary(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      legalName: null == legalName
          ? _self.legalName
          : legalName // ignore: cast_nullable_to_non_nullable
              as String,
      tradeName: null == tradeName
          ? _self.tradeName
          : tradeName // ignore: cast_nullable_to_non_nullable
              as String,
      cnpjMasked: null == cnpjMasked
          ? _self.cnpjMasked
          : cnpjMasked // ignore: cast_nullable_to_non_nullable
              as String,
      emailMasked: null == emailMasked
          ? _self.emailMasked
          : emailMasked // ignore: cast_nullable_to_non_nullable
              as String,
      phoneMasked: null == phoneMasked
          ? _self.phoneMasked
          : phoneMasked // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$AuthUserSummary {
  String get id;
  String get email;
  String get role;
  String? get employeeId;

  /// Create a copy of AuthUserSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthUserSummaryCopyWith<AuthUserSummary> get copyWith =>
      _$AuthUserSummaryCopyWithImpl<AuthUserSummary>(
          this as AuthUserSummary, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthUserSummary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, email, role, employeeId);

  @override
  String toString() {
    return 'AuthUserSummary(id: $id, email: $email, role: $role, employeeId: $employeeId)';
  }
}

/// @nodoc
abstract mixin class $AuthUserSummaryCopyWith<$Res> {
  factory $AuthUserSummaryCopyWith(
          AuthUserSummary value, $Res Function(AuthUserSummary) _then) =
      _$AuthUserSummaryCopyWithImpl;
  @useResult
  $Res call({String id, String email, String role, String? employeeId});
}

/// @nodoc
class _$AuthUserSummaryCopyWithImpl<$Res>
    implements $AuthUserSummaryCopyWith<$Res> {
  _$AuthUserSummaryCopyWithImpl(this._self, this._then);

  final AuthUserSummary _self;
  final $Res Function(AuthUserSummary) _then;

  /// Create a copy of AuthUserSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? employeeId = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: freezed == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AuthUserSummary].
extension AuthUserSummaryPatterns on AuthUserSummary {
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
    TResult Function(_AuthUserSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthUserSummary() when $default != null:
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
    TResult Function(_AuthUserSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthUserSummary():
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
    TResult? Function(_AuthUserSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthUserSummary() when $default != null:
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
    TResult Function(String id, String email, String role, String? employeeId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthUserSummary() when $default != null:
        return $default(_that.id, _that.email, _that.role, _that.employeeId);
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
    TResult Function(String id, String email, String role, String? employeeId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthUserSummary():
        return $default(_that.id, _that.email, _that.role, _that.employeeId);
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
    TResult? Function(String id, String email, String role, String? employeeId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthUserSummary() when $default != null:
        return $default(_that.id, _that.email, _that.role, _that.employeeId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuthUserSummary extends AuthUserSummary {
  const _AuthUserSummary(
      {required this.id,
      required this.email,
      required this.role,
      this.employeeId})
      : super._();

  @override
  final String id;
  @override
  final String email;
  @override
  final String role;
  @override
  final String? employeeId;

  /// Create a copy of AuthUserSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthUserSummaryCopyWith<_AuthUserSummary> get copyWith =>
      __$AuthUserSummaryCopyWithImpl<_AuthUserSummary>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthUserSummary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, email, role, employeeId);

  @override
  String toString() {
    return 'AuthUserSummary(id: $id, email: $email, role: $role, employeeId: $employeeId)';
  }
}

/// @nodoc
abstract mixin class _$AuthUserSummaryCopyWith<$Res>
    implements $AuthUserSummaryCopyWith<$Res> {
  factory _$AuthUserSummaryCopyWith(
          _AuthUserSummary value, $Res Function(_AuthUserSummary) _then) =
      __$AuthUserSummaryCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String email, String role, String? employeeId});
}

/// @nodoc
class __$AuthUserSummaryCopyWithImpl<$Res>
    implements _$AuthUserSummaryCopyWith<$Res> {
  __$AuthUserSummaryCopyWithImpl(this._self, this._then);

  final _AuthUserSummary _self;
  final $Res Function(_AuthUserSummary) _then;

  /// Create a copy of AuthUserSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? employeeId = freezed,
  }) {
    return _then(_AuthUserSummary(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: freezed == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$AuthSession {
  String get accessToken;
  String get tokenType;
  DateTime get expiresAt;
  AuthCompanySummary get company;
  AuthUserSummary get user;

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthSessionCopyWith<AuthSession> get copyWith =>
      _$AuthSessionCopyWithImpl<AuthSession>(this as AuthSession, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthSession &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, accessToken, tokenType, expiresAt, company, user);

  @override
  String toString() {
    return 'AuthSession(accessToken: $accessToken, tokenType: $tokenType, expiresAt: $expiresAt, company: $company, user: $user)';
  }
}

/// @nodoc
abstract mixin class $AuthSessionCopyWith<$Res> {
  factory $AuthSessionCopyWith(
          AuthSession value, $Res Function(AuthSession) _then) =
      _$AuthSessionCopyWithImpl;
  @useResult
  $Res call(
      {String accessToken,
      String tokenType,
      DateTime expiresAt,
      AuthCompanySummary company,
      AuthUserSummary user});

  $AuthCompanySummaryCopyWith<$Res> get company;
  $AuthUserSummaryCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthSessionCopyWithImpl<$Res> implements $AuthSessionCopyWith<$Res> {
  _$AuthSessionCopyWithImpl(this._self, this._then);

  final AuthSession _self;
  final $Res Function(AuthSession) _then;

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresAt = null,
    Object? company = null,
    Object? user = null,
  }) {
    return _then(_self.copyWith(
      accessToken: null == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _self.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      company: null == company
          ? _self.company
          : company // ignore: cast_nullable_to_non_nullable
              as AuthCompanySummary,
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUserSummary,
    ));
  }

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthCompanySummaryCopyWith<$Res> get company {
    return $AuthCompanySummaryCopyWith<$Res>(_self.company, (value) {
      return _then(_self.copyWith(company: value));
    });
  }

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserSummaryCopyWith<$Res> get user {
    return $AuthUserSummaryCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// Adds pattern-matching-related methods to [AuthSession].
extension AuthSessionPatterns on AuthSession {
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
    TResult Function(_AuthSession value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthSession() when $default != null:
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
    TResult Function(_AuthSession value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthSession():
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
    TResult? Function(_AuthSession value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthSession() when $default != null:
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
    TResult Function(String accessToken, String tokenType, DateTime expiresAt,
            AuthCompanySummary company, AuthUserSummary user)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthSession() when $default != null:
        return $default(_that.accessToken, _that.tokenType, _that.expiresAt,
            _that.company, _that.user);
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
    TResult Function(String accessToken, String tokenType, DateTime expiresAt,
            AuthCompanySummary company, AuthUserSummary user)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthSession():
        return $default(_that.accessToken, _that.tokenType, _that.expiresAt,
            _that.company, _that.user);
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
    TResult? Function(String accessToken, String tokenType, DateTime expiresAt,
            AuthCompanySummary company, AuthUserSummary user)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthSession() when $default != null:
        return $default(_that.accessToken, _that.tokenType, _that.expiresAt,
            _that.company, _that.user);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuthSession extends AuthSession {
  const _AuthSession(
      {required this.accessToken,
      required this.tokenType,
      required this.expiresAt,
      required this.company,
      required this.user})
      : super._();

  @override
  final String accessToken;
  @override
  final String tokenType;
  @override
  final DateTime expiresAt;
  @override
  final AuthCompanySummary company;
  @override
  final AuthUserSummary user;

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthSessionCopyWith<_AuthSession> get copyWith =>
      __$AuthSessionCopyWithImpl<_AuthSession>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthSession &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, accessToken, tokenType, expiresAt, company, user);

  @override
  String toString() {
    return 'AuthSession(accessToken: $accessToken, tokenType: $tokenType, expiresAt: $expiresAt, company: $company, user: $user)';
  }
}

/// @nodoc
abstract mixin class _$AuthSessionCopyWith<$Res>
    implements $AuthSessionCopyWith<$Res> {
  factory _$AuthSessionCopyWith(
          _AuthSession value, $Res Function(_AuthSession) _then) =
      __$AuthSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String tokenType,
      DateTime expiresAt,
      AuthCompanySummary company,
      AuthUserSummary user});

  @override
  $AuthCompanySummaryCopyWith<$Res> get company;
  @override
  $AuthUserSummaryCopyWith<$Res> get user;
}

/// @nodoc
class __$AuthSessionCopyWithImpl<$Res> implements _$AuthSessionCopyWith<$Res> {
  __$AuthSessionCopyWithImpl(this._self, this._then);

  final _AuthSession _self;
  final $Res Function(_AuthSession) _then;

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresAt = null,
    Object? company = null,
    Object? user = null,
  }) {
    return _then(_AuthSession(
      accessToken: null == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _self.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      company: null == company
          ? _self.company
          : company // ignore: cast_nullable_to_non_nullable
              as AuthCompanySummary,
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUserSummary,
    ));
  }

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthCompanySummaryCopyWith<$Res> get company {
    return $AuthCompanySummaryCopyWith<$Res>(_self.company, (value) {
      return _then(_self.copyWith(company: value));
    });
  }

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserSummaryCopyWith<$Res> get user {
    return $AuthUserSummaryCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// @nodoc
mixin _$AuthContext {
  AuthCompanySummary get company;
  AuthUserSummary get user;

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthContextCopyWith<AuthContext> get copyWith =>
      _$AuthContextCopyWithImpl<AuthContext>(this as AuthContext, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthContext &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, company, user);

  @override
  String toString() {
    return 'AuthContext(company: $company, user: $user)';
  }
}

/// @nodoc
abstract mixin class $AuthContextCopyWith<$Res> {
  factory $AuthContextCopyWith(
          AuthContext value, $Res Function(AuthContext) _then) =
      _$AuthContextCopyWithImpl;
  @useResult
  $Res call({AuthCompanySummary company, AuthUserSummary user});

  $AuthCompanySummaryCopyWith<$Res> get company;
  $AuthUserSummaryCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthContextCopyWithImpl<$Res> implements $AuthContextCopyWith<$Res> {
  _$AuthContextCopyWithImpl(this._self, this._then);

  final AuthContext _self;
  final $Res Function(AuthContext) _then;

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? company = null,
    Object? user = null,
  }) {
    return _then(_self.copyWith(
      company: null == company
          ? _self.company
          : company // ignore: cast_nullable_to_non_nullable
              as AuthCompanySummary,
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUserSummary,
    ));
  }

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthCompanySummaryCopyWith<$Res> get company {
    return $AuthCompanySummaryCopyWith<$Res>(_self.company, (value) {
      return _then(_self.copyWith(company: value));
    });
  }

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserSummaryCopyWith<$Res> get user {
    return $AuthUserSummaryCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// Adds pattern-matching-related methods to [AuthContext].
extension AuthContextPatterns on AuthContext {
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
    TResult Function(_AuthContext value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthContext() when $default != null:
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
    TResult Function(_AuthContext value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthContext():
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
    TResult? Function(_AuthContext value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthContext() when $default != null:
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
    TResult Function(AuthCompanySummary company, AuthUserSummary user)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthContext() when $default != null:
        return $default(_that.company, _that.user);
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
    TResult Function(AuthCompanySummary company, AuthUserSummary user) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthContext():
        return $default(_that.company, _that.user);
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
    TResult? Function(AuthCompanySummary company, AuthUserSummary user)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthContext() when $default != null:
        return $default(_that.company, _that.user);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuthContext extends AuthContext {
  const _AuthContext({required this.company, required this.user}) : super._();

  @override
  final AuthCompanySummary company;
  @override
  final AuthUserSummary user;

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthContextCopyWith<_AuthContext> get copyWith =>
      __$AuthContextCopyWithImpl<_AuthContext>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthContext &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, company, user);

  @override
  String toString() {
    return 'AuthContext(company: $company, user: $user)';
  }
}

/// @nodoc
abstract mixin class _$AuthContextCopyWith<$Res>
    implements $AuthContextCopyWith<$Res> {
  factory _$AuthContextCopyWith(
          _AuthContext value, $Res Function(_AuthContext) _then) =
      __$AuthContextCopyWithImpl;
  @override
  @useResult
  $Res call({AuthCompanySummary company, AuthUserSummary user});

  @override
  $AuthCompanySummaryCopyWith<$Res> get company;
  @override
  $AuthUserSummaryCopyWith<$Res> get user;
}

/// @nodoc
class __$AuthContextCopyWithImpl<$Res> implements _$AuthContextCopyWith<$Res> {
  __$AuthContextCopyWithImpl(this._self, this._then);

  final _AuthContext _self;
  final $Res Function(_AuthContext) _then;

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? company = null,
    Object? user = null,
  }) {
    return _then(_AuthContext(
      company: null == company
          ? _self.company
          : company // ignore: cast_nullable_to_non_nullable
              as AuthCompanySummary,
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUserSummary,
    ));
  }

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthCompanySummaryCopyWith<$Res> get company {
    return $AuthCompanySummaryCopyWith<$Res>(_self.company, (value) {
      return _then(_self.copyWith(company: value));
    });
  }

  /// Create a copy of AuthContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserSummaryCopyWith<$Res> get user {
    return $AuthUserSummaryCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

// dart format on
