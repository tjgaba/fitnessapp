import 'dart:io';

void main() {
  final projectRoot = _resolveProjectRoot();
  final checks = <ArchitectureCheck>[
    ArchitectureCheck(
      name: 'presentation has no shared_preferences imports',
      directoryPath: _resolveFromRoot(projectRoot, 'lib/presentation'),
      forbiddenPattern: 'package:shared_preferences',
    ),
    ArchitectureCheck(
      name: 'data has no ChangeNotifier usage',
      directoryPath: _resolveFromRoot(projectRoot, 'lib/data'),
      forbiddenPattern: 'ChangeNotifier',
    ),
    ArchitectureCheck(
      name: 'domain has no shared_preferences imports',
      directoryPath: _resolveFromRoot(projectRoot, 'lib/domain'),
      forbiddenPattern: 'package:shared_preferences',
    ),
  ];

  for (final check in checks) {
    final result = check.run();
    final status = result.passed ? 'PASS' : 'FAIL';
    stdout.writeln('$status: ${check.name}');

    for (final violation in result.violations) {
      stdout.writeln('  - $violation');
    }
  }
}

String _resolveProjectRoot() {
  final scriptDirectory = File.fromUri(Platform.script).parent;
  final rootDirectory = scriptDirectory.parent;
  return rootDirectory.path;
}

String _resolveFromRoot(String rootPath, String relativePath) {
  final separator = Platform.pathSeparator;
  final normalized = relativePath.replaceAll('/', separator);
  return '$rootPath$separator$normalized';
}

class ArchitectureCheck {
  final String name;
  final String directoryPath;
  final String forbiddenPattern;

  const ArchitectureCheck({
    required this.name,
    required this.directoryPath,
    required this.forbiddenPattern,
  });

  ArchitectureCheckResult run() {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return ArchitectureCheckResult(
        passed: false,
        violations: <String>['Missing directory: $directoryPath'],
      );
    }

    final violations = <String>[];
    final files = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final content = file.readAsStringSync();
      if (content.contains(forbiddenPattern)) {
        violations.add(file.path);
      }
    }

    return ArchitectureCheckResult(
      passed: violations.isEmpty,
      violations: violations,
    );
  }
}

class ArchitectureCheckResult {
  final bool passed;
  final List<String> violations;

  const ArchitectureCheckResult({
    required this.passed,
    required this.violations,
  });
}
