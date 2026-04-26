// end_session_sort.dart
// Mayson Ostermeyer 04/11/2026
//
// This file defines the endSessionSort function, which processes a session file and updates each athlete's json file with their recorded times from the session.
// It reads the session file, matches athlete names with the start list, and writes the corresponding times to each athlete's file.

// Formatting and structure of json files

//{
//  "name": "Mayson",
//  "sessions": [
//    {
//     "session": "TESTJSON_04_19_2026",
//      "times": [
//        1.27,
//        1.42,
//        1.04,
//        0.97,
//        1.28,
//        1.09,
//        0.97,
//        0.91,
//        1.41,
//        1.34,
//        0.99
//      ]
//    }
//  ]
//}

// IMPORTS
import 'dart:convert';
import 'dart:io';

// Function to process the session file and update each athlete's json file with their recorded times from the session
Future<void> endSessionSort(String sessionPath, List<String> startList) async {
  final sessionFile = File(sessionPath);

  if (!sessionFile.existsSync()) {
    return;
  }

  if (startList.isEmpty) {
    return;
  }

  final raw = sessionFile.readAsStringSync();
  final Map<String, dynamic> sessionData = jsonDecode(raw);

  final String sessionName = sessionData['session'] ?? '';
  final List<dynamic> sessionAthletes = sessionData['athletes'] ?? [];

  if (sessionName.isEmpty) {
    return;
  }

  // Loop through each athlete in the start list, find their corresponding times in the session data, and update their individual json files with the new times
  for (final athleteName in startList) {

    final trimmedName = athleteName.trim();

    if (trimmedName.isEmpty) {
      continue;
    }

    // Create a reference to the athlete's json file
    final athleteFile = File('athletes/$trimmedName.json');

    // If the athlete's file does not exist, create it with an initial structure containing the athlete's name and an empty list of sessions
    if (!athleteFile.existsSync()) {
      athleteFile.createSync(recursive: true);
      athleteFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'name': trimmedName,
          'sessions': <Map<String, dynamic>>[],
        }),
      );
    }

    // Find the athlete's entry in the session data by matching their name, and if found, extract their recorded times for the session
    final matchingAthlete = sessionAthletes.cast<Map<String, dynamic>?>().firstWhere(
      (athlete) => athlete?['name'] == trimmedName,
      orElse: () => null,
    );

    if (matchingAthlete == null) {
      continue;
    }

    // Extract the athlete's times from the session data, ensuring they are in a list of doubles format
    final List<dynamic> rawTimes = matchingAthlete['times'] ?? [];
    final List<double> times = rawTimes
        .map((time) => (time as num).toDouble())
        .toList();

    // Read the existing data from the athlete's json file, update it with the new session and times, and write it back to the file
    final existingRaw = athleteFile.readAsStringSync();
    final Map<String, dynamic> athleteData = existingRaw.trim().isEmpty
        ? {
            'name': trimmedName,
            'sessions': <Map<String, dynamic>>[],
          }
        : jsonDecode(existingRaw);

    // Get the existing sessions for the athlete, add the new session with its times, and update the athlete's data structure
    final List<dynamic> sessions = athleteData['sessions'] ?? [];


    // Add the new session and times to the athlete's list of sessions, ensuring the session name and times are properly structured
    sessions.add({
      'session': sessionName,
      'times': times,
    });

    // Update the athlete's data with their name and the updated list of sessions
    athleteData['name'] = trimmedName;
    athleteData['sessions'] = sessions;

    // Write the updated athlete data back to their json file with proper formatting for readability
    athleteFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(athleteData),
    );
  }
}

