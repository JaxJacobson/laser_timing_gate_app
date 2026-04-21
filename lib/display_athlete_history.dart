// display_athlete_history.dart
// Mayson Ostermeyer 04/14/2026
//
// This file diplays the history of an athlete's times across all sessions. It reads the athlete's .json file from the 'athletes' directory, 
// extracts the session names and times, and displays them in a list format. The times are displayed from newest to oldest.

// The display looks as follows:
// Session 1 ------------------ 1.34 (newest time)
// Session 1 ------------------ 1.56
// Session 2 ------------------ 1.56
// Session 2 ------------------ 1.78
// Session 3 ------------------ 1.78
// Session 3 ------------------ 1.34 (oldest time)

// The user can delete the athlete profile using the delete button in the app bar

// IMPORTS
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';


class AthleteHistoryResult {
  // This class represents a single result in the athlete page, containing the session's name and their recorded time.
  const AthleteHistoryResult({
    // The constructor for the AthleteHistoryResult class, which requires a session name and time to create an instance.
    // This is used to create a list of results that will be displayed in the athlete page.
    // Each section of the list will hold the name of the athlete and their corresponding time for that session.

    // Ex:
    // AthleteHistoryResult(name: 'Session 1', time: '1.34'),
    required this.name,
    required this.time,
  });

  // The name of the session and the time associated with this athlete's result.
  final String name;
  final String time;
}

class DisplayAthleteHistoryPage extends StatelessWidget {
  // This widget displays the athlete history for a specific athlete, showing the names of the sessions and their times in the format described above.
  final String athletePath;

  const DisplayAthleteHistoryPage({
    // The constructor for the DisplayAthleteHistoryPage class, which requires the path to the athlete JSON file to load and display the athlete history.

    super.key,
    required this.athletePath,
  });

    List<AthleteHistoryResult> loadResults() {
      // Read the results from the athlete JSON file and return a list of AthleteHistoryResult objects that contain the session's name and their recorded time for that athlete.
      // The list will be sorted from most recent time to oldest time.

      // If the JSON file looks like this:

/*
{
  "session": "EXAMPLE",
    "athletes": [
      {
        "name": "Session 3",
        "times": [
          1.87,
          1.56,
        ]
      },
      {
        "name": "Session 2",
        "times": [
          1.22,
          1.89,
        ]
      },
      {
        "name": "Session 1",
        "times": [
          1.67,
          1.34,
        ]
      }
    ]
}
*/

      /*
         The list will look as follows:

            [
              AthleteHistoryResult(name: 'Session 1', time: '1.34'),
              AthleteHistoryResult(name: 'Session 1', time: '1.67'),
              AthleteHistoryResult(name: 'Session 2', time: '1.89'),
              AthleteHistoryResult(name: 'Session 2', time: '1.22'),
              AthleteHistoryResult(name: 'Session 3', time: '1.56'),
              AthleteHistoryResult(name: 'Session 3', time: '1.87'),
            ]
      */

      // Obtain the athlete JSON file
      final athleteFile = File(athletePath);

      // If the athlete file does not exist, return an empty list of results.
      if (!athleteFile.existsSync()) {
        return [];
      }

      // Read the contents of the athlete JSON file
      final raw = athleteFile.readAsStringSync();

      // Parses the JSON text into a Dart map
      final Map<String, dynamic> athleteData = jsonDecode(raw);

      // Extract the list of sessions from the athlete data. If there are no sessions, use an empty list as a default value.
      final List<dynamic> sessions = athleteData['sessions'] ?? [];

      // Create a list to hold the AthleteHistoryResult objects and a variable to track the maximum number of times recorded in any session.
      // Inialized to 0, will be updated later
      final List<AthleteHistoryResult> results = [];
      int maxTimes = 0;

      // Loop through each session to find the maximum number of times recorded in any session.
      for (final session in sessions) {
        final List<dynamic> times = session['times'] ?? [];
        if (times.length > maxTimes) {
          maxTimes = times.length;
        }
      }

      // Loop through each session
      for (final session in sessions) {

        // For each session, loop through the times recorded for that session using an index from 0 to maxTimes - 1.
        // This ensures that all times are included in the results list.
        for (int timeIndex = 0; timeIndex < maxTimes; timeIndex++) {

          // Extract the session name and the time for the current index. If there is no time recorded for that index, it will be skipped.
          final String name = session['session'] ?? '';
          final List<dynamic> times = session['times'] ?? [];

          // If there is a time recorded for the current index, create an AthleteHistoryResult object with the session name and time.
          if (timeIndex < times.length) {
            final value = times[timeIndex];
            final displayTime = (value is num)
                ? value.toStringAsFixed(2)
                : value.toString();

            // Add the AthleteHistoryResult object to the results list.
            results.add(
              AthleteHistoryResult(
                name: name,
                time: displayTime,
              ),
            );
          }
        }
      }

      // Reverse the order of the results list so that the most recent times are displayed first, and return the list of AthleteHistoryResult objects.
      return results.reversed.toList();
    }

// The build method constructs the UI for the athlete history page
  @override
  Widget build(BuildContext context) {

    // Extract the file name from the athlete path and remove the .json extension to create a display name for the app bar title.
    final fileName = athletePath.split('\\').last;
    final displayName = fileName.replaceFirst(RegExp(r'\.json$'), '');

    // Load the athlete history results obtained from the loadResults method
    final results = loadResults();

    // Build the Scaffold widget that contains the app bar and the body of the athlete history page.
    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),

      // The actions property of the AppBar contains an IconButton that allows the user to delete the athlete history. When pressed, it shows a confirmation dialog before deleting the session file.
      // BIG TODO!!!!!!!!!!!!!!
      // Delete the athlete data from the session pages!!!!
      // # Ran outta time to do this
      actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,

                // The AlertDialog that appears when the delete icon is pressed, asking the user to confirm if they want to delete the athlete history.
                builder: (context) => AlertDialog(
                  title: const Text('Delete Athlete History'),
                  content: const Text('Are you sure you want to delete this athlete history? This action cannot be undone.'),
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
                        final file = File(athletePath);
                        if (file.existsSync()) {
                          file.deleteSync();
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Athlete history deleted')),
                        );

                        // After deleting the athlete history, return the user back to the main page
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

      // The body of the Scaffold contains a padded Container that displays the athlete history results. 
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
                    'No times recorded for this athlete',
                    style: TextStyle(fontSize: 16),
                  ),
                )

              // If there are results to display, use a ListView.builder to create a scrollable list of the athlete history results, showing the session's name and its corresponding time.
              : ListView.builder(
                
                  // The itemCount is set to the number of results, and the itemBuilder constructs each row of the list with the session's name and its time.
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];

                    return Padding(

                      // Each row has spacing bewteen them equal to 6 pixels
                      padding: const EdgeInsets.symmetric(vertical: 6),

                      child: Row(
                        children: [
                          // Code to display the following format:
                          // Session 1 ------------------------ Time

                          // The session's name is displayed on the left side of the row with a font size of 18.
                          Text(
                            result.name,
                            style: const TextStyle(fontSize: 18),
                          ),

                          // A SizedBox is used to create horizontal spacing of 8 pixels between the session's name and its time.
                          const SizedBox(width: 8),
                          Expanded(

                            // Obtain the maximum width available for the time display and calculate how many dashes can fit in that space
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final dashCount =
                                    (constraints.maxWidth / 8).floor();

                                // Add the calculated number of dashes followed by the session's time to create a visual separation between the name and time, and display it with a font size of 18.
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

