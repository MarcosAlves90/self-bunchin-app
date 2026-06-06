import 'package:flutter_test/flutter_test.dart';

import 'package:bunchin_flutter/core/config/app_config.dart';

void main() {
  test('uses the official API as the default base URL', () {
    expect(
      AppConfig.apiBaseUrl,
      'https://self-bunchin-app.onrender.com/api/v1',
    );
  });
}
