// start_list 2.0
// Jax Jacobson 04/14/26
//
// This file displays the start list page, which shows all start list files that are stored in the start_list directory.
// The user is able to create new start list files, input the athlete names in the file, and sort the files by newest to oldest, 
// oldest to newest, A-Z, or Z-A using a popup menu in the app bar.


import 'dart:io';
import 'package:flutter/material.dart';
import 'sortfiles.dart';
import 'display_start_list.dart';


// StartListPage2 is a StatefulWidget that displays a list of start list files and allows sorting them based on user selection.
class StartListPage2 extends StatefulWidget {
  // Constructor for StartListPage2, which takes an optional key parameter and initializes the widget.
  const StartListPage2({super.key});

  // The createState method creates the mutable state for this widget, which is managed by the _StartListPage2State class.
  @override
  State<StartListPage2> createState() => _StartListPage2State();
}

// _StartListPage2State is the state class for StartListPage2, responsible for managing the list of start list files and the selected sorting option.
class _StartListPage2State extends State<StartListPage2> {
  static const String title =
      'Start Lists'; 


  @override
  // Disposes of the widget when the page is switched. (Automatically called by Flutter)
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  List<File> startListFiles = [];
  late final TextEditingController _fileNameController;
  // By default the files will be sorted by date, with the newest files first.
  SortOption selectedSort = SortOption.newestToOldest;

  // The initState method is called when the state object is first created. It initializes the text controller and loads files.
  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();
    loadStartFiles();
  }

  // loadStartFiles is an asynchronous method that loads the start list files from the 'start_lists' directory and updates the sessionFiles list based on the selected sorting option.
  Future<void> loadStartFiles() async {
    // Change 'start_lists' to <directory_name> if you want to display different files
    final directory = Directory('start_lists');

    // Check if the 'start_lists' directory exists. If it does, list all the .txt files in the directory and sort them using the SortFiles class based on the selected sorting option.
    if (await directory.exists()) {
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.txt'))
          .toList();

      // Update the start list files with newly created or deleted files.
      setState(() {
        startListFiles = SortFiles.sortFiles(files, selectedSort);
      });
    }
  }

  // updateSort is a method that updates the selected sorting option and re-sorts the startListFiles list based on the new sorting option.
  // It calls setState to trigger a rebuild of the widget with the updated sorting.
  void updateSort(SortOption option) {
    setState(() {
      selectedSort = option;
      startListFiles = SortFiles.sortFiles(startListFiles, selectedSort);
    });
  }

  Future<void> addStartListFile(String name) async {
    final fileName = name.trim();
    if (fileName.isEmpty) { // Check if the file name is empty after trimming whitespace
      return;
    }

    final directory = Directory('start_lists');
    await directory.create(recursive: true);

    // Automatically add .txt extension if not provided
    final safeName = fileName.endsWith('.txt') ? fileName : '$fileName.txt'; 
    // Create the path for the new file
    final filePath = '${directory.path}${Platform.pathSeparator}$safeName';   
    final file = File(filePath);

    if (await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Can't create a file with the same name. An error will be displayed.
          SnackBar(content: Text('File "$safeName" already exists.')),
        );
      }
      return;
    }
    // Write an empty string to the new file, so it is added to the directory and list.
    await file.writeAsString('');
    _fileNameController.clear();
    await loadStartFiles();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "$safeName" to start lists.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title = Start Lists
        title: const Text(title),

        // The actions property of the AppBar contains a PopupMenuButton that allows the user to select a sorting option for the start list files.
        // Located in the top right corner of the AppBar
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            initialValue: selectedSort,
            onSelected: updateSort,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.newestToOldest,
                child: Text('Newest to Oldest'),
              ),
              const PopupMenuItem(
                value: SortOption.oldestToNewest,
                child: Text('Oldest to Newest'),
              ),
              const PopupMenuItem(value: SortOption.aToZ, child: Text('A-Z')),
              const PopupMenuItem(value: SortOption.zToA, child: Text('Z-A')),
            ],
          ),
        ],
      ),
      // The body of the Scaffold contains a text field for adding new files and a list of start list buttons.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                // The text inside the text field.
                labelText: 'New start list file name',
                // The text that is displayed when hovering over the text field.
                hintText: 'Enter file name without extension',
                border: OutlineInputBorder(),
              ),
              onSubmitted: addStartListFile,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text( 
                  '*click the start list to open/edit it*',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ElevatedButton(
                  onPressed: () => addStartListFile(_fileNameController.text),
                  child: const Text('Add File'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: startListFiles.length,
                itemBuilder: (context, index) {
                  final file = startListFiles[index];
                  final fileName = file.path.split('\\').last;
                  final displayName = fileName.replaceFirst(
                    RegExp(r'\.txt$'),
                    '',
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // When a start list file button is pressed, navigate to the DisplayStartListPage and pass the file path as an argument to display the start list details.
                            builder: (context) =>
                                DisplayStartListPage(startListPath: file.path),
                          ),
                        );
                      },
                      // The button with the start list file name.
                      child: Text(displayName),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
