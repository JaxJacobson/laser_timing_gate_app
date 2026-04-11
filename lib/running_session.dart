// running_session.dart
// Mayson Ostermeyer 04/11/2026
//
// This file defines the RunningSessionPage, which displays the current session in progress,
// showing the next athletes up and a list of completed athletes with their times. It listens for
// incoming time data from the HC-05 Bluetooth module and updates the session accordingly.

// IMPORTS
import 'dart:async';
import 'package:flutter/material.dart';
import 'BT_HC05.dart';
import 'dart:io';
import 'end_session_sort.dart';



class AthleteResult {
  // Represents an athlete's result with their name and time
  const AthleteResult({
    required this.name,
    required this.time,
  });

  final String name;
  final String time;
}

class RunningSessionPage extends StatefulWidget {
  // The RunningSessionPage displays the current session, showing the next athletes and completed results.
  const RunningSessionPage({
    super.key,
    required this.sessionPath,
    required this.startList,
    required this.hc05Service,
  });

  final String sessionPath;
  final List<String> startList;
  final HC05Service hc05Service;

  @override
  State<RunningSessionPage> createState() => _RunningSessionPageState();
}

class _RunningSessionPageState extends State<RunningSessionPage> {
  // The state for the RunningSessionPage, managing the current index, completed athletes, and timer.

  int currentIndex = 0;
  final List<AthleteResult> completedAthletes = [];

  // Timer to periodically check for new time data from the HC-05 module
  Timer? refreshTimer;

  // Variable to track the last processed time value to avoid duplicate processing
  String lastProcessedTime = '';

  @override
  void initState() {

    // Start a timer to check for new time data from the HC-05 module every 200 milliseconds
    super.initState();

    refreshTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final incomingTime = widget.hc05Service.latest_time.trim();

      if (incomingTime.isEmpty || incomingTime == 'Waiting...') {
        return;
      }

      // Only process the new time if it is different from the last processed time
      if (incomingTime != lastProcessedTime) {
        lastProcessedTime = incomingTime;
        handleNewTime(incomingTime);
      }
    });
  }

  // Handle a new time received from the HC-05 module, updating the completed athletes list and current index
  void handleNewTime(String time) {
    if (widget.startList.isEmpty) {
      return;
    }

    // Add the current athlete and their time to the completed athletes list, then move to the next athlete
    // Update the session file with the new result for record-keeping
    setState(() {
      completedAthletes.insert(
        0,
        AthleteResult(
          name: widget.startList[currentIndex],
          time: time,
        ),
      );

      final athleteName = widget.startList[currentIndex];
      final sessionFile = File(widget.sessionPath);


      // Append the athlete's name and time to the session file for record-keeping
      // Each line in the session file will have the format: "Athlete Name\nTime\n"
      // EX:

      // Session: Mayson_is_faster_than_Marcus_04_11_2026
      // Marcus Gubanyi
      // 132.98
      // Mayson Ostermeyer
      // 0.95
      sessionFile.writeAsStringSync(
        '$athleteName\n$time\n',
        mode: FileMode.append,
      );

      // Move to the next athlete in the start list, wrapping around to the beginning if we reach the end
      currentIndex = (currentIndex + 1) % widget.startList.length;
    });
  }

  // Get the athlete's name at a specific offset from the current index, wrapping around the start list
  String getAthleteAtOffset(int offset) {
    if (widget.startList.isEmpty) {
      return 'No athletes';
    }

    final index = (currentIndex + offset) % widget.startList.length;
    return widget.startList[index];
  }

  // Create a widget to display an athlete's name with a label
  // The label indicates whether the athlete is "Up", "On Deck", or "In The Hole"
  Widget athleteBox(String label, String athleteName) {

    // Returns a styled container displaying the label and athlete's name
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            athleteName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Create a widget to display the list of completed athletes and their times
  // This displays the completed athletes in a scrollable list, showing their name and time with a dashed line in between
  Widget completedListBox() {

    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),

        // If there are no completed athletes, show a message. Otherwise, show a list of completed athletes and their times.
        child: completedAthletes.isEmpty
            ? const Center(
                child: Text(
                  'No athletes have gone yet',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(

                // How many rows to show in the list, based on the number of completed athletes
                itemCount: completedAthletes.length,

                // Build each row in the list to show the athlete's name and time
                itemBuilder: (context, index) {
                  final result = completedAthletes[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [

                        // Show the athlete's name on the left side of the row
                        Text(
                          result.name,
                          style: const TextStyle(fontSize: 18),
                        ),

                        const SizedBox(width: 8),

                        // A dashed line to separate the athlete's name from their time, which expands to fill the space between them
                        // At the end of the dashed line, show the athlete's time
                        // EX: "Marcus Gubanyi ------------- 132.98"
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final dashCount = (constraints.maxWidth / 8).floor();
                              return Text (
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
    );
  }

  // Clean up resources when the page is disposed, canceling the timer
  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  // Build the UI for the RunningSessionPage, showing the next athletes and completed results
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading:false,
        leadingWidth: 120,
        leading: TextButton(

          // When the "End Session" button is pressed,  call endSessionSort to process the session file and update the athletes' files with their times
          // Then take the user back to the home page by popping all routes until the first one
          onPressed: () async {
            await endSessionSort(widget.sessionPath, widget.startList);
            if (!context.mounted) return;
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('End Session'),
        ),
        title: const Text('Running Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // Show the next three athletes up and the list of completed athletes with their times vertically
          children: [
            athleteBox('Up', getAthleteAtOffset(0)),
            const SizedBox(height: 12),
            athleteBox('On Deck', getAthleteAtOffset(1)),
            const SizedBox(height: 12),
            athleteBox('In The Hole', getAthleteAtOffset(2)),
            const SizedBox(height: 12),
            completedListBox(),
          ],
        ),
      ),
    );
  }
}
