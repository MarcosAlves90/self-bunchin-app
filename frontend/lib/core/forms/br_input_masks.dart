import 'package:flutter/services.dart';

class BrInputMasks {
  static const int cnpjDigitCount = 14;
  static const int phoneMinDigitCount = 10;
  static const int phoneMaxDigitCount = 11;

  static const TextInputFormatter cnpjFormatter = _MaskedDigitsFormatter(
    maxDigits: cnpjDigitCount,
    format: formatCnpj,
  );

  static const TextInputFormatter phoneFormatter = _MaskedDigitsFormatter(
    maxDigits: phoneMaxDigitCount,
    format: formatPhone,
  );

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool hasValidCnpjDigits(String value) {
    return digitsOnly(value).length == cnpjDigitCount;
  }

  static bool hasValidPhoneDigits(String value) {
    final digitCount = digitsOnly(value).length;
    return digitCount >= phoneMinDigitCount && digitCount <= phoneMaxDigitCount;
  }

  static String formatCnpj(String value) {
    final digits = digitsOnly(value);
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index == 2 || index == 5) {
        buffer.write('.');
      } else if (index == 8) {
        buffer.write('/');
      } else if (index == 12) {
        buffer.write('-');
      }
      buffer.write(digits[index]);
    }

    return buffer.toString();
  }

  static String formatPhone(String value) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) {
      return '';
    }

    if (digits.length <= 2) {
      return '($digits';
    }

    final ddd = digits.substring(0, 2);
    final localNumber = digits.substring(2);

    if (localNumber.length <= 4) {
      return '($ddd) $localNumber';
    }

    final prefixLength = localNumber.length > 8 ? 5 : 4;
    final safePrefixLength =
        prefixLength > localNumber.length ? localNumber.length : prefixLength;
    final prefix = localNumber.substring(0, safePrefixLength);
    final suffix = localNumber.substring(safePrefixLength);

    if (suffix.isEmpty) {
      return '($ddd) $prefix';
    }

    return '($ddd) $prefix-$suffix';
  }
}

class _MaskedDigitsFormatter extends TextInputFormatter {
  const _MaskedDigitsFormatter({
    required this.maxDigits,
    required this.format,
  });

  final int maxDigits;
  final String Function(String value) format;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final nextDigits = BrInputMasks.digitsOnly(newValue.text);
    final truncatedDigits = nextDigits.length <= maxDigits
        ? nextDigits
        : nextDigits.substring(0, maxDigits);
    final formattedText = format(truncatedDigits);
    final selectionOffset = _selectionOffset(
      formattedText,
      _digitCountBeforeCursor(newValue),
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionOffset),
      composing: TextRange.empty,
    );
  }

  int _digitCountBeforeCursor(TextEditingValue value) {
    final rawOffset = value.selection.baseOffset;
    if (rawOffset <= 0) {
      return 0;
    }

    final safeOffset =
        rawOffset > value.text.length ? value.text.length : rawOffset;
    final textBeforeCursor = value.text.substring(0, safeOffset);
    final digitCount = BrInputMasks.digitsOnly(textBeforeCursor).length;
    return digitCount > maxDigits ? maxDigits : digitCount;
  }

  int _selectionOffset(String formattedText, int digitCount) {
    if (digitCount <= 0) {
      return 0;
    }

    var seenDigits = 0;
    for (var index = 0; index < formattedText.length; index++) {
      final character = formattedText[index];
      if (_isDigit(character)) {
        seenDigits += 1;
      }

      if (seenDigits == digitCount) {
        return index + 1;
      }
    }

    return formattedText.length;
  }

  bool _isDigit(String character) {
    return character.codeUnitAt(0) >= 48 && character.codeUnitAt(0) <= 57;
  }
}
