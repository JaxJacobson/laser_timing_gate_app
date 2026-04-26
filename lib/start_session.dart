// start_session.dart
// Mayson Ostermeyer 04/11/2026
//
// This file defines the StartSessionPage, which allows users to connect to the HC-05 Bluetooth module,
// select a start list, and enter a session name before starting a new session. It also handles loading
// available start lists from the 'start_lists' directory.


// IMPORTS
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'BT_HC05.dart';
import 'running_session.dart';
import 'dart:convert';


class StartSessionPage extends StatefulWidget {
  // Defines the StartSessionPage, which is the initial screen where the users connect to the HC-05 board and enter sessions details
  // As a stateful widget, it will update is display based on user interactions

  // Constructor for StartSessionPage, which is empty since we don't need to pass any initial data to this page
  const StartSessionPage({super.key});

  // Override the createState method to return an instance of _StartSessionPageState, which will manage the state of this page
  @override
  State<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends State<StartSessionPage> {
  // This class manages the state of the StartSessionPage, including handling the connection to the HC-05 module,
  // loading start lists, and navigating to the RunningSessionPage when a session is started.


  static const String title = 'Current Session';

  // HC-05 service instance to manage Bluetooth communication
  // See BT_HC05.dart for details on how this class works
  final HC05Service hc05Service = HC05Service();

  // defines variables to hold the latest data from the HC-05 module, the selected start list name, and the session name entered by the user
  String latestTime = 'Waiting...';
  String? selectedListName;
  List<String> startListFiles = [];

  // Text editing controller for the session name input field, allowing us to retrieve the text entered by the user
  final TextEditingController sessionNameController = TextEditingController();
  String session_name = '';

  // Timer to periodically refresh the lastestTime variable from HC-05
  Timer? refreshTimer;

  void loadStartLists() {
    // This function loads the available start lists from the 'start_lists' directory and updates the startListFiles variable with the file names

    final directory = Directory('start_lists');

    if (directory.existsSync()) {
      final files = directory
          .listSync() // List all files in the directory
          .whereType<File>() // Filter to only include files (not directories)
          .where((file) => file.path.endsWith('.txt')) // Filter to only include .txt files
          .map((file) => file.uri.pathSegments.last) // Extract just the file name from the path
          .toList(); // Convert to a list

      // Update the state with the list of start list files, which will trigger a rebuild of the UI to show the dropdown menu with these files
      setState(() {
        startListFiles = files;
      });
    }
  }


  Future<void> connectButton() async {
    // This function is called when the user presses the "Connect to HC-05" button. It attempts to connect to the HC-05 module and 
    // starts a timer to periodically update the latestData variable with the latest time received from the HC-05 module.

    // Show a snackbar to indicate that the connection process has started
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Attempt to connect to the HC-05 module and get the result message (success or failure)
    final result = await hc05Service.connect();

    // Prevents crashing if user exits mid-connection
    if (!mounted) return;

    // Cancel any existing timer to prevent multiple timers from running if the user presses the connect button multiple times
    // Please don't spam the connect button :(
    refreshTimer?.cancel();

    // Show a snackbar with the result of the connection attempt (success or failure message)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );

    // TODO: DONT ALLOW THE USER TO START A SESSION IF THE CONNECTION IS NOT MADE!!!!!!!!!!!!!
  }

void startButton() async {
  // This function is called when the user presses the "Start Session" button. It validates the session name and selected start list, creates a new session file, 
  // and navigates to the RunningSessionPage with the session details.

  // Trim the session name to remove any leading or trailing whitespace
  final baseName = session_name.trim();

  // Validate that the session name is not empty and that a start list has been selected. If either of these conditions is not met, show a snackbar with an error message and return early to prevent starting the session.
  if (baseName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a session name')),
    );
    return;
  }

  if (selectedListName == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a start list')),
    );
    return;
  }

  // Append a timestamp to the session name
  final now = DateTime.now();
  final dateSuffix =
      '${now.month.toString().padLeft(2, '0')}_'
      '${now.day.toString().padLeft(2, '0')}_'
      '${now.year}';

  final fullFileName = '${baseName}_$dateSuffix';
  final sessionFile = File('sessions/$fullFileName.json');

  // Create the session file and potentially overwrite an existing file with the same name. (if same name on same day)
  // Due to time constraints, I did not let a session be appended, mostly because I didn't want to deal with ensuring to
  // not write times to athlete's profiles that they already ran.
  // AAAAAA, so do NOT do that!!!!!
  sessionFile.createSync(recursive: true);

  // Create a JSON structure for the session file, which includes the session name and an empty list of athletes.
  final sessionJson = {
    'session': fullFileName,
    'athletes': <Map<String, dynamic>>[],
  };

  // Write the session JSON data to the session file with pretty formatting (indentation). This will rewrite the JSON file for the session with the initial structure.
  sessionFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(sessionJson),
  );

  // Prevents crashing if user exits mid-session start
  if (!mounted) return;


  // Create a duplicate of the selected start list to pass to the RunningSessionPage. 
  // RunningSessionPage will modify the start list as athletes run, and we want to keep the original start list unchanged for future reference.
  final file = File('start_lists/$selectedListName');
  final OGstartList = file
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty)
      .toList();
  final startList = List<String>.from(OGstartList);

  // Navigate to the RunningSessionPage, passing the session file path, the start list, the original start list, and the HC-05 service instance. 
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RunningSessionPage(
        sessionPath: sessionFile.path,
        startList: startList,
        OGstartList: OGstartList,
        hc05Service: hc05Service,
      ),
    ),
  );
}

  // Override the initState method to load the available start lists when the page is first created. This will populate the dropdown menu with the start list options.
  @override
  void initState() {
    super.initState();
    loadStartLists();
  }

  // Override the build method to define the UI of the StartSessionPage, which includes buttons for connecting to the HC-05 module and starting a session, 
  // a dropdown menu for selecting a start list, and a text field for entering the session name.
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 0, 85)),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(title),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connect button to initiate connection to the HC-05 module
            ElevatedButton(
              onPressed: connectButton,
              child: const Text('Connect to HC-05'),
            ),

            // Spacing between the connect button and the dropdown menu
            const SizedBox(height: 20),

            // Dropdown menu to select a start list from the available options loaded from the 'start_lists' directory
            DropdownButton<String>(
              value: selectedListName,
              hint: const Text('Select List'),

              // Grab the file names from the startListFiles variable and create a DropdownMenuItem for each file name to display in the dropdown menu
              items: startListFiles.map((fileName) {
                return DropdownMenuItem<String>(
                  value: fileName,
                  child: Text(fileName),
                );

              // Convert the iterable of DropdownMenuItems to a list, which is required by the items property of the DropdownButton
              }).toList(),

              // When the user selects a new start list from the dropdown menu, update the selectedListName variable and trigger a rebuild of the UI to reflect the new selection
              onChanged: (String? newValue) {
                setState(() {
                  selectedListName = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // Text field for entering the session name, which updates the session_name variable as the user types.
            TextField(
              // The controller allows us to retrieve the text entered by the user, and the onChanged callback updates the session_name variable whenever the text changes
              controller: sessionNameController,
              onChanged: (value) {
                setState(() {
                  session_name = value;
                });
              },

              // Input decoration for the text field, which includes a border and a label prompting the user to enter a session name
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Session Name',
              ),
            ),
            const SizedBox(height: 20),

            // Start Session button to navigate to the RunningSessionPage with the session details when pressed
            // Calls the startButton function, which validates the input and handles the session file creation and navigation
            ElevatedButton(
              onPressed: startButton,
              child: const Text('Start Session'),
            ),

          ],
        ),
      ),
    ));
  }

// runs when screen closes
// Disposes of the HC-05 connection and stops the timer to prevent memory leaks.
  @override
  void dispose() {
    refreshTimer?.cancel();
    hc05Service.dispose();
    super.dispose();
  }
}


