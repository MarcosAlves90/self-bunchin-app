import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bunchin_flutter/contracts/location.dart';
import 'package:flutter/material.dart';

part 'punch.freezed.dart';

enum ShiftStatus { checkedOut, working, onBreak }

enum PunchType { checkIn, breakStart, breakEnd, checkOut }

@freezed
abstract class PunchRecord with _$PunchRecord {
  const PunchRecord._();

  const factory PunchRecord({
    required PunchType type,
    required DateTime timestamp,
    required String detail,
    PunchLocationSnapshot? location,
  }) = _PunchRecord;

  String get title {
    return switch (type) {
      PunchType.checkIn => 'Entrada',
      PunchType.breakStart => 'Pausa',
      PunchType.breakEnd => 'Retorno',
      PunchType.checkOut => 'Saída',
    };
  }

  IconData get icon {
    return switch (type) {
      PunchType.checkIn => Icons.login_rounded,
      PunchType.breakStart => Icons.pause_circle_outline_rounded,
      PunchType.breakEnd => Icons.play_circle_outline_rounded,
      PunchType.checkOut => Icons.logout_rounded,
    };
  }
}