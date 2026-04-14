import 'dart:io';

class FileTransfer {

  static Future<void> saveAthlete(String name)  // Unused function to save athlete name
  async {                                       // Necessary for TDD test to pass, but not used in the app.

    final basePath = Directory.current.path; // Get the current directory path
    final dir = Directory('$basePath/start_lists'); // Get the start_lists directory

    if (!await dir.exists()) {

      await dir.create(recursive: true); // Create start_lists if it doesn't exist
    }
    final file = File('$basePath/start_lists/start_list.txt');  // Put the default file in start_lists dir
    await file.writeAsString('$name\n', mode: FileMode.append); // Append the athlete name to the default file
  }


  static String get basePath => Directory.current.path; // Get the current directory path
  static Future<void> saveAthleteToCustomList({ // Actual function used in the app to save athlete name

    required String name,     // Athlete name
    required String fileName  // Custom file name

  }) async {

    final dir = Directory('$basePath/start_lists'); // Get the start_lists directory

    if (!await dir.exists()) {

      await dir.create(recursive: true); // Create start_lists if it doesn't exist

    }

    final file = File('$basePath/start_lists/$fileName');  // Put the custom file in start_lists dir
    await file.writeAsString('$name\n', mode: FileMode.append); // Append the athlete name to the custom file

  }
}