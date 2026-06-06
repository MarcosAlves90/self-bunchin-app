import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../scripts/release_info.dart';

void main() {
  group('release catalog', () {
    test('maps 1.x.x versions to the Woodpecker release line', () {
      final info = buildReleaseInfo(
        catalog: _catalog(),
        pubspecContents: 'version: 1.4.2+18',
      );

      expect(info.version, '1.4.2');
      expect(info.buildNumber, 18);
      expect(info.lineName, 'Woodpecker');
      expect(info.releaseName, 'Woodpecker 1.4.2');
      expect(info.tagName, 'v1.4.2');
    });

    test('maps 2.x.x versions to the Atlas release line', () {
      final info = buildReleaseInfo(
        catalog: _catalog(),
        pubspecContents: 'version: 2.0.0+101',
      );

      expect(info.lineName, 'Atlas');
      expect(info.releaseName, 'Atlas 2.0.0');
      expect(info.tagName, 'v2.0.0');
    });

    test('rejects versions without a configured major release line', () {
      expect(
        () => buildReleaseInfo(
          catalog: _catalog(),
          pubspecContents: 'version: 3.0.0+1',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects duplicate major release lines', () {
      final catalog = _catalog();
      final lines = catalog['releaseLines'] as List<dynamic>;
      lines.add(<String, dynamic>{
        'major': 1,
        'name': 'Duplicate',
        'status': 'planned',
        'description': 'Invalid duplicate',
      });

      expect(() => validateCatalog(catalog), throwsA(isA<StateError>()));
    });

    test('requires Android appbundle publishing to stay enabled', () {
      final catalog = _catalog();
      final platforms = catalog['platforms'] as Map<String, dynamic>;
      final android = platforms['android'] as Map<String, dynamic>;
      android['enabled'] = false;

      expect(() => validateCatalog(catalog), throwsA(isA<StateError>()));
    });
  });
}

Map<String, dynamic> _catalog() {
  return jsonDecode('''
{
  "schemaVersion": 1,
  "versioning": {
    "scheme": "semver",
    "lineIdentity": "major",
    "releaseNamePattern": "{lineName} {version}",
    "buildNumberPolicy": "monotonic"
  },
  "platforms": {
    "android": {
      "enabled": true,
      "artifact": "appbundle",
      "signing": {
        "propertiesFile": "android/key.properties",
        "exampleFile": "android/key.properties.example"
      }
    },
    "ios": {
      "enabled": false,
      "reservedForFuture": true
    },
    "web": {
      "enabled": false,
      "reservedForFuture": true
    }
  },
  "releaseLines": [
    {
      "major": 1,
      "name": "Woodpecker",
      "status": "active",
      "description": "Linha 1.x.x"
    },
    {
      "major": 2,
      "name": "Atlas",
      "status": "planned",
      "description": "Linha 2.x.x"
    }
  ]
}
''') as Map<String, dynamic>;
}
