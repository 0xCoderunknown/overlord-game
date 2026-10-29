import 'dart:io';

/// Automated Invariant Verification Gate for Overlord AI Maintainers.
/// Checks repository Dart formatting, screen line limits (<400),
/// 100% offline pledge (no network SDKs in source/release manifests), static analysis, and full test suite.
void main() async {
  stdout.writeln('======================================================');
  stdout.writeln('📟 OVERLORD — Vault Bunker 42 AI Invariant Gate');
  stdout.writeln('======================================================\n');

  int exitCode = 0;

  stdout.writeln('🧹 [1/5] Checking repository Dart formatting...');
  final repositoryFilesResult = await Process.run('git', [
    'ls-files',
    '-co',
    '--exclude-standard',
    '-z',
  ], runInShell: true);

  if (repositoryFilesResult.exitCode != 0) {
    stdout.writeln(
      '❌ Could not list repository files:\n'
      '${repositoryFilesResult.stdout}${repositoryFilesResult.stderr}',
    );
    exitCode = 1;
  } else {
    final dartPaths = (repositoryFilesResult.stdout as String)
        .split('\x00')
        .where((path) => path.endsWith('.dart'))
        .toList();

    final formatResult = await Process.run('dart', [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...dartPaths,
    ], runInShell: true);

    if (formatResult.exitCode != 0) {
      stdout.writeln(
        '❌ Dart formatting check failed:\n'
        '${formatResult.stdout}${formatResult.stderr}',
      );
      exitCode = 1;
    } else {
      stdout.writeln('✅ All repository Dart files are cleanly formatted.');
    }
  }

  stdout.writeln(
    '\n🔍 [2/5] Checking presentation/screen file line limits (< 400)...',
  );
  final presentationDirs = ['lib/screens', 'lib/widgets'];
  final oversizedFiles = <Map<String, Object>>[];

  for (final dirPath in presentationDirs) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final lineCount = entity.readAsLinesSync().length;
        if (lineCount >= 400) {
          oversizedFiles.add({'path': entity.path, 'lines': lineCount});
        }
      }
    }
  }

  if (oversizedFiles.isNotEmpty) {
    stdout.writeln(
      '❌ ${oversizedFiles.length} presentation file(s) exceed 400 lines:',
    );
    for (final f in oversizedFiles) {
      stdout.writeln('   - ${f['path']}: ${f['lines']} lines');
    }
    exitCode = 1;
  } else {
    stdout.writeln(
      '✅ All presentation files are strictly within the 400-line limit.',
    );
  }

  stdout.writeln(
    '\n🔒 [3/5] Verifying 100% Offline Pledge (Zero Network Imports & Clean Release Manifest)...',
  );
  final forbiddenPackagePatterns = [
    RegExp(
      r'''import\s+['"]package:(?:http|dio|firebase|analytics|cloud_firestore|google_fonts)['"]''',
    ),
  ];

  final violationHits = <String>[];
  if (repositoryFilesResult.exitCode == 0) {
    final dartSourcePaths = (repositoryFilesResult.stdout as String)
        .split('\x00')
        .where((path) => path.startsWith('lib/') && path.endsWith('.dart'));

    for (final path in dartSourcePaths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      final content = file.readAsStringSync();
      for (final pattern in forbiddenPackagePatterns) {
        if (pattern.hasMatch(content)) {
          violationHits.add(
            '$path: matched forbidden network pattern ${pattern.pattern}',
          );
        }
      }
    }
  }

  // Check production AndroidManifest.xml
  final releaseManifest = File('android/app/src/main/AndroidManifest.xml');
  if (releaseManifest.existsSync()) {
    final manifestContent = releaseManifest.readAsStringSync();
    if (manifestContent.contains('android.permission.INTERNET')) {
      violationHits.add(
        'android/app/src/main/AndroidManifest.xml: declares production INTERNET permission',
      );
    }
  }

  // Check pubspec.yaml dependencies
  final pubspec = File('pubspec.yaml');
  if (pubspec.existsSync()) {
    final pubContent = pubspec.readAsStringSync();
    final forbiddenDeps = ['http:', 'dio:', 'firebase_core:', 'google_fonts:'];
    for (final dep in forbiddenDeps) {
      if (pubContent.contains(dep)) {
        violationHits.add('pubspec.yaml: declares remote dependency $dep');
      }
    }
  }

  if (violationHits.isNotEmpty) {
    stdout.writeln(
      '❌ 100% Offline Pledge violated! Remote network dependencies found:',
    );
    for (final hit in violationHits) {
      stdout.writeln('   - $hit');
    }
    exitCode = 1;
  } else {
    stdout.writeln(
      '✅ 100% Offline Pledge verified! No network or analytics packages detected.',
    );
  }

  stdout.writeln('\n🩺 [4/5] Running flutter analyze...');
  final analyzeResult = await Process.run('flutter', [
    'analyze',
  ], runInShell: true);
  if (analyzeResult.exitCode != 0) {
    stdout.writeln(
      '❌ Analyzer reported issues:\n'
      '${analyzeResult.stdout}${analyzeResult.stderr}',
    );
    exitCode = 1;
  } else {
    stdout.writeln('✅ Analyzer passed with zero issues!');
  }

  stdout.writeln('\n🧪 [5/5] Running all unit & widget tests...');
  final testResult = await Process.run('flutter', ['test'], runInShell: true);
  if (testResult.exitCode != 0) {
    stdout.writeln('❌ Tests failed:\n${testResult.stdout}${testResult.stderr}');
    exitCode = 1;
  } else {
    stdout.writeln('✅ All unit and widget tests passed!');
  }

  stdout.writeln('\n======================================================');
  if (exitCode == 0) {
    stdout.writeln('🎉 ALL OVERLORD INVARIANT GATES PASSED! Safe to commit.');
  } else {
    stdout.writeln(
      '❌ INVARIANT VIOLATIONS DETECTED. Resolve before concluding.',
    );
  }
  stdout.writeln('======================================================');

  exit(exitCode);
}
