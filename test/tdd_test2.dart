import 'dart:io';
import 'package:test/test.dart';
import '../lib/file_service.dart';

void main() {
  test(
    'athlete name is saved to start_lists directory', 
    () async {
      final name = "Jax";

      
      await FileTransfer.saveAthlete(name); // Call the function to move the athlete name
                                            // to the start_lists directory.
                                          
      final file = File('${Directory.current.path}/start_lists/start_list.txt');

      
      expect(await file.exists(), true);  // Check file exists

      
      final contents = await file.readAsString();
      expect(contents.contains(name), true);  // Check the content of the file is correct.
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
                                          
      final file = File('${Directory.current.path}/start_lists/$fileName');
      
      expect(await file.exists(), true);  // Check file exists
      
      final contents = await file.readAsString();
      expect(contents.contains(name), true);  // Check the athlete's name is in the custom file
  });
  test(
    'the already created start list names are shown in a dropdown menu', 
    () async {
      final basePath = Directory.current.path;
      final dir = Directory('$basePath/start_lists');

      if (!await dir.exists()) {
        await dir.create(recursive: true); // Create start_lists if it doesn't exist
      }

      final file1 = File('$basePath/start_lists/list1.txt');  // Custom file in start_lists dir
      final file2 = File('$basePath/start_lists/list2.txt');

      await file1.writeAsString('Jax');
      await file2.writeAsString('Mayson');

      final files = await FileTransfer.getStartLists(); // Get the directory of start lists to show in dropdown

      expect(files.contains('list1.txt'), true); // Check list1.txt is in the dropdown menu
      expect(files.contains('list2.txt'), true); // Check list2.txt is in the dropdown menu
  });
}