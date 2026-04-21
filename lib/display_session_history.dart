// display_session_history.dart
// Mayson Ostermeyer - 2024-06-11
//
// This file displays the session history based on the specified session button that the user clicked on in the session_history.dart file.
// It reads the session JSON file and displays the time in the following format in order of the most recent time to the oldest time:

// Athlete 1  --------------------- Time (most recent time)
// Athelete 2 --------------------- Time
// Athelete 3 --------------------- Time (oldest time)

// The user can delete the session history by clicking on the delete icon in the top right corner of the app bar.

// IMPORTS
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';


class SessionHistoryResult {
  // This class represents a single result in the session history, containing the athlete's name and their recorded time.

  const SessionHistoryResult({
    // The constructor for the SessionHistoryResult class, which requires a name and time to create an instance.
    // This is used to create a list of reults that will be displayed in the session history page.
    // Each section of the list will hold the name of the athlete and their corresponding time for that session.

    // Ex:
    // SessionHistoryResult(name: 'Athlete 1', time: '1.34'),

    required this.name,
    required this.time,
  });

  // The name of the athlete and the time associated with this session history result.
  final String name;
  final String time;
}

class DisplaySessionsHistoryPage extends StatelessWidget {
  // This widget displays the session history for a specific session, showing the names of the athletes and their times in the formatt described above.
  final String sessionPath;

  const DisplaySessionsHistoryPage({
    // The constructor for the DisplaySessionsHistoryPage class, which requires the path to the session JSON file to load and display the session history.

    super.key,
    required this.sessionPath,
  });

    List<SessionHistoryResult> loadResults() {
      // Read the results from the session JSON file and return a list of SessionHistoryResult objects that contain the athlete's name and their recorded time for that session.
      // The list will be sorted from most recent time to oldest time.

      // If the JSON file looks like this:

/*
{
  "session": "EXAMPLE",
    "athletes": [
      {
        "name": "Athlete 3",
        "times": [
          1.87,
          1.89,
        ]
      },
      {
        "name": "Athlete 2",
        "times": [
          1.56,
          1.67,
        ]
      },
      {
        "name": "Athlete 1",
        "times": [
          1.22,
          1.34,
        ]
      }
    ]
}
*/

      /*
         The list will look as follows:

            [
              SessionHistoryResult(name: 'Athlete 1', time: '1.34'),
              SessionHistoryResult(name: 'Athlete 2', time: '1.67'),
              SessionHistoryResult(name: 'Athlete 3', time: '1.89'),
              SessionHistoryResult(name: 'Athlete 1', time: '1.22'),
              SessionHistoryResult(name: 'Athlete 2', time: '1.56'),
              SessionHistoryResult(name: 'Athlete 3', time: '1.87'),
            ]
      */

      // Obtain the session JSON file
      final sessionFile = File(sessionPath);

      // If the session file does not exist, return an empty list of results.
      if (!sessionFile.existsSync()) {
        return [];
      }

      // Read the contents of the session file
      final raw = sessionFile.readAsStringSync();

      // Parses the JSON text into a Dart map
      final Map<String, dynamic> sessionData = jsonDecode(raw);

      // Extract the list of athletes from the session data. If there are no athletes, use an empty list.
      final List<dynamic> athletes = sessionData['athletes'] ?? [];

      // Create a list to hold the session history resultS
      final List<SessionHistoryResult> results = [];

      // Determine the maximum number of times recorded for any athlete in the session to ensure we display all times for all athletes.
      // Initialize maxTimes to 0, which will be updated as below
      int maxTimes = 0;

      // Iterate through each athlete and check the number of times they have recorded. Update maxTimes if the current athlete has more times than the previously recorded maximum.
      for (final athlete in athletes) {
        final List<dynamic> times = athlete['times'] ?? [];
        if (times.length > maxTimes) {
          maxTimes = times.length;
        }
      }

      // Loop through each time index from 0 to maxTimes -1
      for (int timeIndex = 0; timeIndex < maxTimes; timeIndex++) {

        // Loop through each athlete at the current time index
        for (final athlete in athletes) {

          // Extract the athlete's name and their list of times. If the athlete does not have a name or times, use default values.
          final String name = athlete['name'] ?? '';
          final List<dynamic> times = athlete['times'] ?? [];

          // If the index of the current time is less than the number of times recorded for the athlete, it means there is a valid time to display for this athlete at this index.
          if (timeIndex < times.length) {

            // Extract the time value at the current index for the athlete. If the value is a number, format it to two decimal places; otherwise, convert it to a string as is.
            final value = times[timeIndex];
            final displayTime = (value is num)
                ? value.toStringAsFixed(2)
                : value.toString();

            // Create a new SessionHistoryResult with the athlete's name and the formatted time, and add it to the results list.
            results.add(
              SessionHistoryResult(
                name: name,
                time: displayTime,
              ),
            );
          }
        }
      }

      // Reverse the order of the results list to display the most recent times first, and return the reversed list.
      return results.reversed.toList();
    }


  // The build method constructs the UI for the session history page
  @override
  Widget build(BuildContext context) {

    // Extract the file name from the session path and remove the .json extension to create a display name for the app bar title.
    final fileName = sessionPath.split('\\').last;
    final displayName = fileName.replaceFirst(RegExp(r'\.json$'), '');

    // Load the session history results obtained from the loadResults method
    final results = loadResults();

    // Build the Scaffold widget that contains the app bar and the body of the session history page.
    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),

      // The actions property of the AppBar contains an IconButton that allows the user to delete the session history. When pressed, it shows a confirmation dialog before deleting the session file.
      // BIG TODO!!!!!!!!!!!!!!
      // Delete the session data from the athlete pages!!!!
      // # Ran outta time to do this
      actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,

                // The AlertDialog that appears when the delete icon is pressed, asking the user to confirm if they want to delete the session history.
                builder: (context) => AlertDialog(
                  title: const Text('Delete Session History'),
                  content: const Text('Are you sure you want to delete this session history? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // If the user cancels the deletion, simply close the dialog without making any changes.
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      // If the user confirms the deletion, delete the session file from the device, close the dialog, show a SnackBar confirming the deletion, and navigate back to the main page.
                      onPressed: () {
                        final file = File(sessionPath);
                        if (file.existsSync()) {
                          file.deleteSync();
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session history deleted')),
                        );

                        // After deleting the session history, return the user back to the main page
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // The body of the Scaffold contains a padded Container that displays the session history results. 
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(

          // The Container is styled with a white background, a black border, and rounded corners. It takes up the full width of the screen and has padding for spacing.
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),

          child: results.isEmpty

          // If there are no results to display, show a message indicating that no times were recorded for this session.  
              ? const Center(
                  child: Text(
                    'No times recorded for this session',
                    style: TextStyle(fontSize: 16),
                  ),
                )

              // If there are results to display, use a ListView.builder to create a scrollable list of the session history results, showing the athlete's name and their corresponding time.
              : ListView.builder(
                
                  // The itemCount is set to the number of results, and the itemBuilder constructs each row of the list with the athlete's name and their time.
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];

                    return Padding(

                      // Each row has spacing bewteen them equal to 6 pixels
                      padding: const EdgeInsets.symmetric(vertical: 6),

                      child: Row(
                        children: [
                          // Code to display the following format:
                          // Athlete 1 ------------------------ Time

                          // The athlete's name is displayed on the left side of the row with a font size of 18.
                          Text(
                            result.name,
                            style: const TextStyle(fontSize: 18),
                          ),

                          // A SizedBox is used to create horizontal spacing of 8 pixels between the athlete's name and their time.
                          const SizedBox(width: 8),
                          Expanded(

                            // Obtain the maximum width available for the time display and calculate how many dashes can fit in that space
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final dashCount =
                                    (constraints.maxWidth / 8).floor();

                                // Add the calculated number of dashes followed by the athlete's time to create a visual separation between the name and time, and display it with a font size of 18.
                                return Text(
                                  '${'-' * dashCount}${result.time}',
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(fontSize: 18),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

}

