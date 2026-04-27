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
import 'dart:convert';



class AthleteResult {

  const AthleteResult({
    // The constructor for the AthleteResult class, which requires a name and time to create an instance.
    // This is used to create a list of reults that will be displayed in box below the 'up', 'on deck', and 'in the hole' 
    // boxes on the RunningSessionPage. Each section of the list will hold the name of the athlete
    // and their corresponding time for that session.

    // Ex:
    // AthleteResult(name: 'Athlete 1', time: '1.34'),
    
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
    required this.OGstartList,
  });

  final String sessionPath;
  final List<String> startList;
  final HC05Service hc05Service;
  final List<String> OGstartList; // Original start list to keep track of the athletes in their original order

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

  // Initialize the state and start a timer to check for new time data from the HC-05 module every 200 milliseconds.
  // When new time data is received, it is processed and the session is updated accordingly.
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

  void handleNewTime(String time) {
      // Handle a new time received from the HC-05 module, updating the completed athletes list and current index
  // Formatting and structure of session json files
  //{
  //"session": "TESTJSON_04_19_2026",
  //"athletes": [
  //  {
  //    "name": "Mayson",
  //    "times": [
  //      1.27,
  //      1.42,
  //      1.04,
  //    ]
  //  },
  //  {
  //    "name": "Evan",
  //    "times": [
  //      0.91,
  //      0.99,
  //      1.21,
  //    ]
  //  },
  //  {
  //    "name": "Jax",
  //    "times": [
  //      1.06,
  //      0.97,
  //      1.33,
  //    ]
  //  }
  // ]
  //}
  
  if (widget.startList.isEmpty) {
    return;
  }

  setState(() {
    // Get the athlete's name at the current index in the start list
    final athleteName = widget.startList[currentIndex];

    completedAthletes.insert(
      // Add the athlete and their time to the list of completed athletes, showing the most recent result at the top
      0,
      AthleteResult(
        name: athleteName,
        time: time,
      ),
    );

    final sessionFile = File(widget.sessionPath);

    if (sessionFile.existsSync()) {
      // Read the existing session data, update the athlete's times, and write it back to the session file
      final raw = sessionFile.readAsStringSync();
      final Map<String, dynamic> sessionData = jsonDecode(raw);

      final List<dynamic> athletes = sessionData['athletes'] ?? [];

      final existingIndex = athletes.indexWhere(
        (athlete) => athlete['name'] == athleteName,
      );

      // Try to parse the incoming time as a double, and if successful, add it to the athlete's times in the session data
      final parsedTime = double.tryParse(time);

      if (existingIndex >= 0) {
        // If the athlete already exists in the session data, add the new time to their list of times
        final List<dynamic> times = athletes[existingIndex]['times'] ?? [];
        if (parsedTime != null) {
          times.add(parsedTime);
        }
        athletes[existingIndex]['times'] = times;
      } else {
        // If the athlete does not exist in the session data, create a new entry for them with the new time
        athletes.add({
          'name': athleteName,
          'times': parsedTime != null ? [parsedTime] : <double>[],
        });
      }

      // Update the session data with the modified athletes list and write it back to the session file
      sessionData['athletes'] = athletes;

      sessionFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(sessionData),
      );
    }

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

  void skipAthleteUp() {
  // Skip athlete that is up

  if (widget.startList.isEmpty) {
    return;
  }

  setState(() {
    // Move the current Index forward triggering the up, one deck, and in-the-hole names to update
    currentIndex = (currentIndex + 1) % widget.startList.length;
  });
}

void removeAthleteUpFromCycle() {
  // remove athlete up from the start list.
  // This athlete will no longer appear in the rotation.
  
 if (widget.startList.isEmpty) {
  showMessage('No athletes left in the cycle.');
  return;
}

  setState(() {
    // Remove the athlete at the current index from the start list, which will update the up, one deck, and in-the-hole names to reflect the change
    widget.startList.removeAt(currentIndex);

    if (widget.startList.isEmpty) {
      // If the start list is now empty after removing the athlete, reset the current index and show a message
      currentIndex = 0;
      return;
    }

    if (currentIndex >= widget.startList.length) {
      // If the current index is now out of bounds after removing the athlete, wrap it around to the beginning of the list
      currentIndex = 0;
    }
  });
}

void deleteLastTime() {
  // Delete the last recorded time for the most recent athlete, removing it from the completed athletes list and updating the session file accordingly

  if (completedAthletes.isEmpty) {
    // If there are no completed athletes, show a message and return since there is no time to delete
    showMessage('No recorded time to delete.');
    return;
}


  setState(() {
    // Remove the most recent athlete result from the completed athletes list, which will update the UI to reflect the change
    final lastResult = completedAthletes.removeAt(0);
    final sessionFile = File(widget.sessionPath);

    if (!sessionFile.existsSync()) {
      return;
    }

    // Read the existing session data
    final raw = sessionFile.readAsStringSync();
    final Map<String, dynamic> sessionData = jsonDecode(raw);
    final List<dynamic> athletes = sessionData['athletes'] ?? [];

    // Find the index of the athlete in the session data that matches the name of the last result
    final athleteIndex = athletes.indexWhere(
      (athlete) => athlete['name'] == lastResult.name,
    );

    if (athleteIndex >= 0) {
      // Grab the list of times for that athlete
      final List<dynamic> times = athletes[athleteIndex]['times'] ?? [];

      if (times.isNotEmpty) {
        // Remove the last time from the athlete's list of times
        times.removeLast();
      }

      // Update the athlete's times in the session data and write it back to the session file
      athletes[athleteIndex]['times'] = times;
      sessionData['athletes'] = athletes;

      // Write the updated session data back to the session file with proper formatting
      sessionFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(sessionData),
      );
    }
  });
}

Future<void> editLastTime() async {
  // Edit the last recorded time for the most recent athlete, allowing the user to input a new time and updating the session file accordingly

  if (completedAthletes.isEmpty) {
    showMessage('No recorded time to edit.');
    return;
}

  final lastResult = completedAthletes.first;
  final controller = TextEditingController(text: lastResult.time);

  final newTime = await showDialog<String>(
    // Show a dialog with a text field to input the new time, pre-filled with the current time for the most recent athlete. When the user saves, return the new time. If they cancel, return null.
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Last Time'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'New Time',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  // If the new time is null (user canceled) or empty, do nothing
  if (newTime == null || newTime.isEmpty) {
    return;
  }

  final parsedTime = double.tryParse(newTime);
  if (parsedTime == null) {
    showMessage('Enter a valid number for the time.');
    return;
}

  setState(() {
    // Update the most recent athlete result in the completed athletes list with the new time, which will update the UI to reflect the change
    completedAthletes[0] = AthleteResult(
      name: lastResult.name,
      time: newTime,
    );

    // Read the existing session data
    final sessionFile = File(widget.sessionPath);

    if (!sessionFile.existsSync()) {
      return;
    }

    // Find the athlete in the session data that matches the name of the last result and update
    final raw = sessionFile.readAsStringSync();
    final Map<String, dynamic> sessionData = jsonDecode(raw);
    final List<dynamic> athletes = sessionData['athletes'] ?? [];

    // Find the index of the athlete in the session data that matches the name of the last result
    final athleteIndex = athletes.indexWhere(
      (athlete) => athlete['name'] == lastResult.name,
    );

    if (athleteIndex >= 0) {
      // Grab the list of times for that athlete
      final List<dynamic> times = athletes[athleteIndex]['times'] ?? [];

      // Update the last time in the athlete's list of times with the new parsed time
      if (times.isNotEmpty) {
        times[times.length - 1] = parsedTime;
      }

      // Update the athlete's times in the session data and write it back to the session file
      athletes[athleteIndex]['times'] = times;
      sessionData['athletes'] = athletes;

      sessionFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(sessionData),
      );
    }
  });
}

Future<void> changeAthleteForLastTime() async {
  // Change the athlete associated with the last recorded time, allowing the user to select a different athlete from the original start list and updating the session file accordingly

  if (completedAthletes.isEmpty) {
    showMessage('No recorded time to reassign.');
    return;
}

  final lastResult = completedAthletes.first;
  String selectedAthlete = lastResult.name;

  // Show a dialog with a dropdown to select a different athlete from the original start list, pre-selected with the current athlete for the most recent time
  final newAthlete = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Change Athlete'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return DropdownButton<String>(
              value: selectedAthlete,
              isExpanded: true,
              items: widget.OGstartList.map((athlete) {
                return DropdownMenuItem<String>(
                  value: athlete,
                  child: Text(athlete),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() {
                    selectedAthlete = value;
                  });
                }
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selectedAthlete),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  // If the new athlete is null (user canceled) or the same as the current athlete, do nothing
  if (newAthlete == null || newAthlete == lastResult.name) {
    return;
  }

  final parsedTime = double.tryParse(lastResult.time);

  setState(() {
    // Update the most recent athlete result in the completed athletes list with the new athlete's name, which will update the UI to reflect the change
    completedAthletes[0] = AthleteResult(
      name: newAthlete,
      time: lastResult.time,
    );

    final sessionFile = File(widget.sessionPath);

    if (!sessionFile.existsSync()) {
      return;
    }

    final raw = sessionFile.readAsStringSync();
    final Map<String, dynamic> sessionData = jsonDecode(raw);
    final List<dynamic> athletes = sessionData['athletes'] ?? [];

    final oldAthleteIndex = athletes.indexWhere(
      // Find the index of the athlete in the session data that matches the name of the last result (the old athlete)
      (athlete) => athlete['name'] == lastResult.name,
    );

    if (oldAthleteIndex >= 0) {
      // Grab the list of times for the old athlete and remove the last time, since we are reassigning that time to a different athlete
      final List<dynamic> oldTimes = athletes[oldAthleteIndex]['times'] ?? [];
      if (oldTimes.isNotEmpty) {
        oldTimes.removeLast();
      }
      athletes[oldAthleteIndex]['times'] = oldTimes;
    }

    final newAthleteIndex = athletes.indexWhere(
      // Find the index of the athlete in the session data that matches the new athlete's name selected by the user
      (athlete) => athlete['name'] == newAthlete,
    );

    if (newAthleteIndex >= 0) {
      // If the new athlete already exists in the session data, add the reassigned time to their list of times
      final List<dynamic> newTimes = athletes[newAthleteIndex]['times'] ?? [];
      if (parsedTime != null) {
        newTimes.add(parsedTime);
      }
      athletes[newAthleteIndex]['times'] = newTimes;
    } else {
      // If the new athlete does not exist in the session data, create a new entry for them with the reassigned time
      athletes.add({
        'name': newAthlete,
        'times': parsedTime != null ? [parsedTime] : <double>[],
      });
    }

    // Update the session data with the modified athletes list and write it back to the session file with proper formatting
    sessionData['athletes'] = athletes;

    // Write the updated session data back to the session file with proper formatting
    sessionFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(sessionData),
    );
  });
}

void resetStartList() {
  // Reset the start list to the original start list, restoring all athletes back into the cycle in their original order.
  // The current index will be updated to point to the same athlete that is currently up.

  if (widget.OGstartList.isEmpty) {
    showMessage('Original start list is empty.');
    return;
  }

  // Get the name of the athlete that is currently up before resetting the start list, so we can find their index in the original start list and set the current index to that after resetting
  final currentUpAthlete =
      widget.startList.isEmpty ? null : widget.startList[currentIndex];

  setState(() {
    // Clear the current start list and add all athletes from the original start list back into it, restoring the original order of athletes in the cycle
    widget.startList
      ..clear()
      ..addAll(widget.OGstartList);

    // Find the index of the current athlete in the restored start list and update the current index accordingly
    if (currentUpAthlete == null) {
      currentIndex = 0;
      return;
    }

    // Update the current index to point to the same athlete that is currently up by finding their index in the original start list
    final restoredIndex = widget.startList.indexOf(currentUpAthlete);
    currentIndex = restoredIndex;
  });
}

void showMessage(String message) {
  // Utility function to show a SnackBar message at the bottom of the screen
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
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
            await endSessionSort(widget.sessionPath, widget.OGstartList);
            if (!context.mounted) return;
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('End Session'),
        ),
        title: const Text('Running Session'),
    actions: [
      // A popup menu button in the app bar with options to skip the athlete up, remove the athlete up from the cycle, delete the last recorded time,
      // edit the last recorded time, or change the athlete associated with the last recorded time. Each option triggers a different function to update the session accordingly.

  PopupMenuButton<String>(
    // When an option is selected from the popup menu, call the corresponding function to update the session based on the selected action

    onSelected: (value) async {
  switch (value) {
    case 'skip_up':
      skipAthleteUp();
      break;
    case 'remove_up':
      removeAthleteUpFromCycle();
      break;
    case 'delete_last_time':
      deleteLastTime();
      break;
    case 'edit_last_time':
      await editLastTime();
      break;
    case 'change_last_athlete':
      await changeAthleteForLastTime();
      break;
    case 'reset_start_list':
      resetStartList();
      break;
  }
},
// The items in the popup menu, each with a value that corresponds to a specific action to update the session when selected
    itemBuilder: (context) => const [
      PopupMenuItem(
        value: 'skip_up',
        child: Text('Skip Athlete Up'),
      ),
      PopupMenuItem(
        value: 'remove_up',
        child: Text('Remove Athlete Up From Cycle'),
      ),
      PopupMenuItem(
        value: 'delete_last_time',
        child: Text('Delete Last Time'),
      ),
      PopupMenuItem(
        value: 'edit_last_time',
        child: Text('Edit Last Time'),
      ),
      PopupMenuItem(
        value: 'change_last_athlete',
        child: Text('Change Athlete For Last Time'),
      ),
      PopupMenuItem(
        value: 'reset_start_list',
        child: Text("Reset Start List"),
      ),
    ],
  ),
],
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
