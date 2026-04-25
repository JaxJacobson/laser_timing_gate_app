// tdd_test2.dart
// Jax Jacobson 04/12/2026
// 
// This file tests the process of saving an athlete's name to a start list file in the 
// start_lists directory, making sure the correct file name is saved in the start_lists
// directory, and file names being displayed in a dropdown menu.


import 'dart:io';
import 'package:test/test.dart';
import 'package:laser_timing_gate_app/file_service.dart';


void main() {
  test(
    'athlete name is saved to start_lists directory', 
    () async {
      final name = "Jax";
      
      // Call the function to move the athlete name to the start_lists directory.
      await FileTransfer.saveAthlete(name); 
                                          
      // Check that the file was created in the start_lists directory and contains the athlete's name.
      final file = File('${Directory.current.path}/start_lists/start_list.txt');

      // Check file exists
      expect(await file.exists(), true);  
      
      // Check the content of the file is correct.
      final contents = await file.readAsString();
      expect(contents.contains(name), true);  
  });

  test(
    'name the file that will hold the athlete names', 
    () async {
      final name = "Jax";
      final fileName = 'custom_SL_name.txt';

      await FileTransfer.saveAthleteToCustomList(
      name: name,         // Specify the athlete name to save
      fileName: fileName, // Specify the custom file name to save the athlete name
      );
                                          
      // Check that the file was created in the start_lists directory.
      final file = File('${Directory.current.path}/start_lists/$fileName');
      
      // Check file exists
      expect(await file.exists(), true);  
      
      // Check the athlete's name is in the custom file
      final contents = await file.readAsString();
      expect(contents.contains(name), true);  
  });

  test(
    'the already created start list names are shown in a dropdown menu', 
    () async {
      // Current working directory and path to start_lists directory
      final basePath = Directory.current.path;
      final dir = Directory('$basePath/start_lists');

      // Create start_lists if it doesn't exist
      if (!await dir.exists()) {
        await dir.create(recursive: true); 
      }

      // Custom files in start_lists directory
      final file1 = File('$basePath/start_lists/list1.txt');  
      final file2 = File('$basePath/start_lists/list2.txt');

      // Create the custom files with some content
      await file1.writeAsString('Jax');
      await file2.writeAsString('Mayson');

      // Get the directory of start lists to show in dropdown
      final files = await FileTransfer.getStartLists(); 

      // Check if the custom files are included in the dropdown list.
      expect(files.contains('list1.txt'), true);
      expect(files.contains('list2.txt'), true);
  });
}