// end_session_sort.dart
// Mayson Ostermeyer 04/11/2026
//
// This file defines the endSessionSort function, which processes a session file and updates each athlete's txt file with their recorded times from the session.
// It reads the session file, matches athlete names with the start list, and writes the corresponding times to each athlete's file on separate lines.

// IMPORTS
import 'dart:io';

// The endSessionSort function takes the path to the session file and a list of athlete names from the start list.
Future<void> endSessionSort(String sessionPath, List<String> startList) async {
  final sessionFile = File(sessionPath);

  if (!sessionFile.existsSync()) {
    return;
  }

  if (startList.isEmpty) {
    return;
  }

  // Read all lines from the session file to process the athlete names and their corresponding times
  final lines = sessionFile.readAsLinesSync();

  if (lines.isEmpty) {
    return;
  }

  // The first line of the session file is the session name, which should be written first in each athlete's txt file
  final sessionName = lines[0].trim();

  // Loop through each athlete name in the start list and check for matches in the session file
  for (final athleteName in startList) {
    final trimmedName = athleteName.trim();

    if (trimmedName.isEmpty) {
      continue;
    }

    // For each athlete in the start list, create a reference to their txt file in the 'athletes' directory
    final athleteFile = File('athletes/$trimmedName.txt');

    if (!athleteFile.existsSync()) {
      continue;
    }

    // Collect all times for the current athlete from the session file by matching their name and extracting the corresponding time values
    final times = <String>[];

    // The session file is expected to have lines in the format: athlete name followed by their time on the next line.
    // Loop through the session file lines, checking for matches with the current athlete name and collecting their times
    for (int i = 1; i < lines.length - 1; i += 2) {
      final sessionAthleteName = lines[i].trim();

      // If the athlete name in the session file matches the current athlete from the start list, extract the corresponding time from the next
      // line and add it to the times list
      if (sessionAthleteName == trimmedName) {
        final time = lines[i + 1].trim();

        if (time.isNotEmpty) {
          times.add(time);
        }
      }
    }

    // Read any existing lines in the athlete file so previous session data is not overwritten
    final existingLines = athleteFile.readAsLinesSync();

    // Add the new session name followed by all collected times for this athlete
    final newLines = <String>[
      ...existingLines,
      sessionName,
      ...times,
    ];

    // Write the old data plus the new session data back to the athlete file
    athleteFile.writeAsStringSync(newLines.join('\n'));
  }
}



