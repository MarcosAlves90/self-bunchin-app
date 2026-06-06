import 'dart:convert';
import 'dart:io';

class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.buildNumber,
    required this.lineName,
    required this.releaseName,
    required this.tagName,
  });

  final String version;
  final int buildNumber;
  final String lineName;
  final String releaseName;
  final String tagName;

  Map<String, Object> toJson() => <String, Object>{
        'version': version,
        'buildNumber': buildNumber,
        'lineName': lineName,
        'releaseName': releaseName,
        'tagName': tagName,
      };
}

Map<String, dynamic> readJsonFile(String relativePath) {
  final file = File(relativePath);
  if (!file.existsSync()) {
    throw StateError('Missing required file: $relativePath');
  }

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Map<String, dynamic> readPubspec(String pubspecContents) {
  final match = RegExp(
    r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
    multiLine: true,
  ).firstMatch(pubspecContents);

  if (match == null) {
    throw StateError('Could not parse version from pubspec.yaml.');
  }

  return <String, dynamic>{
    'version': match.group(1)!,
    'buildNumber': int.parse(match.group(2)!),
  };
}

Map<String, dynamic> releaseLineForMajor(
    List<dynamic> releaseLines, int major) {
  for (final dynamic entry in releaseLines) {
    final line = entry as Map<String, dynamic>;
    if (line['major'] == major) {
      return line;
    }
  }
  throw StateError('No release line found for major version $major.');
}

void validateCatalog(Map<String, dynamic> catalog) {
  if (catalog['schemaVersion'] != 1) {
    throw StateError('Unsupported release catalog schema version.');
  }

  final versioning = catalog['versioning'] as Map<String, dynamic>?;
  if (versioning == null) {
    throw StateError('Missing versioning section in release catalog.');
  }

  if (versioning['scheme'] != 'semver') {
    throw StateError('Release catalog must use semver.');
  }
  if (versioning['lineIdentity'] != 'major') {
    throw StateError('Release line identity must stay major.');
  }
  if (versioning['releaseNamePattern'] != '{lineName} {version}') {
    throw StateError('Release name pattern must stay "{lineName} {version}".');
  }
  if (versioning['buildNumberPolicy'] != 'monotonic') {
    throw StateError('Build number policy must stay monotonic.');
  }

  final releaseLines = catalog['releaseLines'] as List<dynamic>?;
  if (releaseLines == null || releaseLines.isEmpty) {
    throw StateError('Release catalog needs at least one release line.');
  }

  final majors = <int>{};
  for (final dynamic entry in releaseLines) {
    final line = entry as Map<String, dynamic>;
    final major = line['major'];
    final name = line['name'];

    if (major is! int || major < 1) {
      throw StateError('Each release line must have a positive integer major.');
    }
    if (name is! String || name.trim().isEmpty) {
      throw StateError('Each release line must have a non-empty name.');
    }
    if (!majors.add(major)) {
      throw StateError('Duplicate release line major: $major.');
    }
  }

  final platforms = catalog['platforms'] as Map<String, dynamic>?;
  final androidConfig = platforms?['android'] as Map<String, dynamic>?;
  if (androidConfig == null) {
    throw StateError('Release catalog must include Android platform config.');
  }
  if (androidConfig['enabled'] != true ||
      androidConfig['artifact'] != 'appbundle') {
    throw StateError(
        'Android release config must stay enabled for appbundle publishing.');
  }
}

ReleaseInfo buildReleaseInfo({
  required Map<String, dynamic> catalog,
  required String pubspecContents,
}) {
  validateCatalog(catalog);

  final pubspec = readPubspec(pubspecContents);
  final version = pubspec['version'] as String;
  final major = int.parse(version.split('.').first);
  final releaseLines = catalog['releaseLines'] as List<dynamic>;
  final line = releaseLineForMajor(releaseLines, major);
  final lineName = line['name'] as String;

  return ReleaseInfo(
    version: version,
    buildNumber: pubspec['buildNumber'] as int,
    lineName: lineName,
    releaseName: '$lineName $version',
    tagName: 'v$version',
  );
}

ReleaseInfo loadReleaseInfo() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    throw StateError('Missing required file: pubspec.yaml');
  }

  return buildReleaseInfo(
    catalog: readJsonFile('release/catalog.json'),
    pubspecContents: pubspecFile.readAsStringSync(),
  );
}

void validate() {
  final info = loadReleaseInfo();

  stdout.writeln('Release catalog valid.');
  stdout.writeln('Version: ${info.version}+${info.buildNumber}');
  stdout.writeln(
      'Release line: ${info.lineName} (major ${info.version.split('.').first})');
  stdout.writeln('Release name: ${info.releaseName}');
  stdout.writeln('Tag: ${info.tagName}');
}

void describe() {
  stdout.writeln(loadReleaseInfo().releaseName);
}

void jsonOutput() {
  stdout.writeln(jsonEncode(loadReleaseInfo().toJson()));
}

void githubEnv() {
  final info = loadReleaseInfo();
  stdout.writeln('RELEASE_VERSION=${info.version}');
  stdout.writeln('RELEASE_BUILD_NUMBER=${info.buildNumber}');
  stdout.writeln('RELEASE_LINE_NAME=${info.lineName}');
  stdout.writeln('RELEASE_NAME=${info.releaseName}');
  stdout.writeln('RELEASE_TAG=${info.tagName}');
}

void main(List<String> args) {
  final command = args.isEmpty ? 'validate' : args.first;

  switch (command) {
    case 'validate':
      validate();
      return;
    case 'describe':
      describe();
      return;
    case 'json':
      jsonOutput();
      return;
    case 'github-env':
      githubEnv();
      return;
    default:
      stderr.writeln(
          'Usage: dart run scripts/release_info.dart [validate|describe|json|github-env]');
      exitCode = 64;
  }
}
