import 'dart:io';

class FileService {
  static Future<void> saveAthleteToStartList(String name) async {
    final dir = Directory('start_lists'); // Directory for start lists

    if (!await dir.exists()) {
      await dir.create(); // Create start_lists if it doesn't exist
    }

    final file = File('start_lists/athletes.txt'); // Put start list in start_lists

    await file.writeAsString('$name\n', mode: FileMode.append); // Append name to file with a newline
  }
}