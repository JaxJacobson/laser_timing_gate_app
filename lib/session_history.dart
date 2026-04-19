// session_history.dart
// Mayson Ostermeyer 04/14/2026
//
// This file defines the SessionHistoryPage widget, which displays a list of session history files (.txt) stored in the 'sessions' directory.
// The user can sort the files by date (newest to oldest or oldest to newest) or alphabetically (A-Z or Z-A) using a popup menu in the app bar. 
// Tapping on a file opens the DisplaySessionHistoryPage to show the session details.


// IMPORTS
import 'dart:io';
import 'package:flutter/material.dart';
import 'sortlist.dart';
import 'display_session_history.dart';

// SessionHistoryPage is a StatefulWidget that displays a list of session history files and allows sorting them based on user selection.
class SessionHistoryPage extends StatefulWidget {
  // Constructor for SessionHistoryPage, which takes an optional key parameter and initializes the widget.
  const SessionHistoryPage({super.key});

  // The createState method creates the mutable state for this widget, which is managed by the _SessionHistoryPageState class.
  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

// _SessionHistoryPageState is the state class for SessionHistoryPage, responsible for managing the list of session files and the selected sorting option.
class _SessionHistoryPageState extends State<SessionHistoryPage> {
  static const String title = 'Sessions'; // Change to start_lists if you want to display start lists instead of sessions

  List<File> sessionFiles = [];
  // By default the files will be sorted by date, with the newest files first.
  SortOption selectedSort = SortOption.newestToOldest;

  // The initState method is called when the state object is first created. It calls the loadSessionFiles method to load the session files from the 'sessions' directory.
  @override
  void initState() {
    super.initState();
    loadSessionFiles();
  }

  // loadSessionFiles is an asynchronous method that loads the session files from the 'sessions' directory and updates the sessionFiles list based on the selected sorting option.
  Future<void> loadSessionFiles() async {
    final directory = Directory('sessions');

    // Check if the 'sessions' directory exists. If it does, list all the .json files in the directory and sort them using the SortList class based on the selected sorting option.
    if (await directory.exists()) {
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      // Update the sessionFiles list with the sorted files and call setState to trigger a rebuild of the widget with the new data.
      setState(() {
        sessionFiles = SortList.sortFiles(files, selectedSort);
      });
    }
  }

  // updateSort is a method that updates the selected sorting option and re-sorts the sessionFiles list based on the new sorting option.
  // It calls setState to trigger a rebuild of the widget with the updated sorting.
  void updateSort(SortOption option) {
    setState(() {
      selectedSort = option;
      sessionFiles = SortList.sortFiles(sessionFiles, selectedSort);
    });
  }

  // The build method builds the UI for the SessionHistoryPage widget. It returns a Scaffold with an AppBar and a ListView that displays the session files as buttons.
  // The AppBar includes a PopupMenuButton that allows the user to select the sorting option
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        
  // The actions property of the AppBar contains a PopupMenuButton that allows the user to select a sorting option for the session files.
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
        const PopupMenuItem(
          value: SortOption.aToZ,
          child: Text('A-Z'),
        ),
        const PopupMenuItem(
          value: SortOption.zToA,
          child: Text('Z-A'),
            ),
          ],
        ),
       ],
      ),
      // The body of the Scaffold contains a ListView.builder that builds a list of ElevatedButtons for each session file.
      // Tapping on a button navigates to the DisplaySessionHistoryPage, passing the file path as an argument.
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessionFiles.length,
        itemBuilder: (context, index) {
          final file = sessionFiles[index];
          final fileName = file.path.split('\\').last;
          final displayName = fileName.replaceFirst(RegExp(r'\.json$'), '');

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // When a session file button is pressed, navigate to the DisplaySessionHistoryPage and pass the file path as an argument to display the session details.
                  builder: (context) => DisplaySessiosHistoryPage(
                    sessionPath: file.path,
                    ),
                ),
              );
              },
              child: Text(displayName),
            ),
          );
        },
      ),
    );
  }
}
