// file_service.dart
// Jax Jacobson 04/13/26
//
// This file was used when setting up the TDD tests for the start list page.
// It takes names inputted from the Start List page and appends them to a designated .txt file in
// the start_lists directory. It does work, but it is not being used because I wanted to be
// able to edit and delete the names in the files. This function does not allow that.



import 'dart:io';

class FileTransfer {

  // This function saves the athlete's name to a default start list file in the start_lists directory.
  static Future<void> saveAthlete(String name)  // 
  async {                                       

    // Get the current directory path and the path to the start_lists directory
    final basePath = Directory.current.path; 
    final dir = Directory('$basePath/start_lists'); 

    if (!await dir.exists()) {
      // Create start_lists if it doesn't exist
      await dir.create(recursive: true); 
    }
    // Put the default file in start_lists directory and append the athlete name to the file
    final file = File('$basePath/start_lists/start_list.txt');  
    await file.writeAsString('$name\n', mode: FileMode.append); 
  }

  // Get the current directory path
  static String get basePath => Directory.current.path; 
  // This function saves the athlete's name to a custom start list file.
  static Future<void> saveAthleteToCustomList({ 

    required String name,       // Athlete name
    required String fileName    // Custom file name

  }) async {

    // Get the start_lists directory
    final dir = Directory('$basePath/start_lists'); 

    if (!await dir.exists()) {
      // Create start_lists if it doesn't exist
      await dir.create(recursive: true); 
    }

    // Put the custom file in start_lists directory and append the athlete name to the custom file
    final file = File('$basePath/start_lists/$fileName');
    await file.writeAsString('$name\n', mode: FileMode.append);

  }
  // This function retrieves the names of the start list files for the dropdown menu in the start list page.
  static Future<List<String>> getStartLists() async {

    // Get the start_lists directory
    final dir = Directory('$basePath/start_lists'); 

    if (!await dir.exists()) {
      // Create start_lists if it doesn't exist
      await dir.create(recursive: true); 
    }

    // Lists the .txt files with 'list' for the TDD test.
    final files = dir.listSync().whereType<File>().where((file) {
      final name = file.uri.pathSegments.last;
      return name.startsWith('list');
    }).toList();

    // Return the list of files for the dropdown menu, extracting just the file names from the full paths.
    return files.map((file) => file.uri.pathSegments.last).toList();
  }
}