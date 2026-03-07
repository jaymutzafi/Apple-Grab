import 'package:path/path.dart' as p;

String flutterGrabTextPathForJsonPath(String jsonPath) {
  final String extension = p.extension(jsonPath);
  if (extension.toLowerCase() == '.json') {
    return p.setExtension(jsonPath, '.txt');
  }
  return '$jsonPath.txt';
}
