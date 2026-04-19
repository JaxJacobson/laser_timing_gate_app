// tdd_test1.dart
// Mayson Ostermeyer 04/19/2026
//
// This file contains unit tests for the endSessionSort function defined in end_session_sort.dart.
// The tests verify that the function correctly processes a session json file and updates each athlete's json file with their recorded times from the session.

// IMPORTS
import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:laser_timing_gate_app/end_session_sort.dart';

void main() {
  test(
    // This test verifies that the endSessionSort function correctly identifies the first athlete in the start list
    // and finds that athlete's json file in the 'athletes' directory.
    // The test sets up a temporary directory structure, creates a session json file with the appropriate format,
    // and checks that the athlete's json file still exists after calling endSessionSort.
    'passes when the json file for the first athlete in the start list is found',
    () async {
      // Set up a temporary directory and create the necessary files for the test
      final tempDir = Directory.systemTemp.createTempSync('end_session_sort_test');
      final originalDirectory = Directory.current;

      try {
        // Change the current working directory to the temporary directory for the duration of the test
        Directory.current = tempDir.path;

        // Create the 'athletes' and 'sessions' directories
        final athletesDir = Directory('athletes')..createSync();
        final sessionsDir = Directory('sessions')..createSync();

        // Create a json file for the athlete "Mayson" in the 'athletes' directory
        final athleteFile = File('${athletesDir.path}/Mayson.json')
          ..writeAsStringSync(
            jsonEncode({
              'name': 'Mayson',
              'sessions': [],
            }),
          );

        // Create a session json file in the 'sessions' directory with the appropriate format for endSessionSort
        final sessionFile = File('${sessionsDir.path}/session_name.json')
          ..writeAsStringSync(
            jsonEncode({
              'session': 'TESTJSON_04_19_2026',
              'athletes': [
                {
                  'name': 'Mayson',
                  'times': [1.27],
                },
              ],
            }),
          );

        // Define the start list with "Mayson" as the first athlete
        final startList = ['Mayson', 'Evan', 'Jax'];

        // Call endSessionSort with the session file path and start list
        await endSessionSort(sessionFile.path, startList);

        // Check that the athlete file for "Mayson" still exists after calling endSessionSort
        expect(athleteFile.existsSync(), isTrue);
      } finally {
        Directory.current = originalDirectory;
        tempDir.deleteSync(recursive: true);
      }
    },
  );

  test(
    // This test verifies that the endSessionSort function correctly processes the session json file
    // and records all times for the first athlete in the start list into their json file.
    // The test checks that the athlete json file contains one session entry with the correct session name
    // and all recorded times for that athlete.
    'records all times for the first athlete into their json file',
    () async {
      // Set up a temporary directory and create the necessary files for the test
      final tempDir = Directory.systemTemp.createTempSync('end_session_sort_test');
      final originalDirectory = Directory.current;

      try {
        // Change the current working directory to the temporary directory for the duration of the test
        Directory.current = tempDir.path;

        // Create the 'athletes' and 'sessions' directories
        Directory('athletes').createSync();
        Directory('sessions').createSync();

        final athleteFile = File('athletes/Mayson.json')
          ..writeAsStringSync(
            jsonEncode({
              'name': 'Mayson',
              'sessions': [],
            }),
          );

        // Create a session json file with multiple times for "Mayson" to test that all times are recorded correctly
        final sessionFile = File('sessions/session_name.json')
          ..writeAsStringSync(
            jsonEncode({
              'session': 'TESTJSON_04_19_2026',
              'athletes': [
                {
                  'name': 'Mayson',
                  'times': [1.27, 1.42, 1.04, 0.97],
                },
                {
                  'name': 'Jax',
                  'times': [1.06, 0.97],
                },
                {
                  'name': 'Evan',
                  'times': [0.91, 0.99],
                },
              ],
            }),
          );

        final startList = ['Mayson', 'Jax', 'Evan'];

        // Call endSessionSort with the session file path and start list
        await endSessionSort(sessionFile.path, startList);

        // Read and decode the athlete json file for "Mayson" to verify that the session and times were recorded correctly
        final athleteJson = jsonDecode(athleteFile.readAsStringSync());

        // Check that the athlete json file for "Mayson" contains the correct name and one session entry
        expect(athleteJson['name'], 'Mayson');
        expect(athleteJson['sessions'], [
          {
            'session': 'TESTJSON_04_19_2026',
            'times': [1.27, 1.42, 1.04, 0.97],
          },
        ]);
      } finally {
        Directory.current = originalDirectory;
        tempDir.deleteSync(recursive: true);
      }
    },
  );

  test(
    // This test verifies that the endSessionSort function correctly processes the session json file
    // and records a session entry for each athlete in the start list into their respective json files.
    // Each athlete json file should keep the athlete's name and contain a sessions list with that athlete's times
    // from the session json file.
    'records the session data for each athlete into their own json files',
    () async {
      // Set up a temporary directory and create the necessary files for the test
      final tempDir = Directory.systemTemp.createTempSync('end_session_sort_test');
      final originalDirectory = Directory.current;

      try {
        // Change the current working directory to the temporary directory for the duration of the test
        Directory.current = tempDir.path;

        Directory('athletes').createSync();
        Directory('sessions').createSync();

        // Create json files for the athletes "Mayson", "Jax", and "Evan" in the 'athletes' directory
        final maysonFile = File('athletes/Mayson.json')
          ..writeAsStringSync(
            jsonEncode({
              'name': 'Mayson',
              'sessions': [],
            }),
          );

        final jaxFile = File('athletes/Jax.json')
          ..writeAsStringSync(
            jsonEncode({
              'name': 'Jax',
              'sessions': [],
            }),
          );

        final evanFile = File('athletes/Evan.json')
          ..writeAsStringSync(
            jsonEncode({
              'name': 'Evan',
              'sessions': [],
            }),
          );

        // Create a session json file with entries for "Mayson", "Jax", and "Evan"
        // to test that each athlete gets their own session data written correctly
        final sessionFile = File('sessions/session_name.json')
          ..writeAsStringSync(
            jsonEncode({
              'session': 'TESTJSON_04_19_2026',
              'athletes': [
                {
                  'name': 'Mayson',
                  'times': [1.27, 1.42, 1.04, 0.97],
                },
                {
                  'name': 'Evan',
                  'times': [0.91, 0.99, 1.21],
                },
                {
                  'name': 'Jax',
                  'times': [1.06, 0.97, 1.33],
                },
              ],
            }),
          );

        final startList = ['Mayson', 'Jax', 'Evan'];

        // Call endSessionSort with the session file path and start list
        await endSessionSort(sessionFile.path, startList);

        // Check that each athlete json file contains the correct name and the correct session data
        expect(jsonDecode(maysonFile.readAsStringSync()), {
          'name': 'Mayson',
          'sessions': [
            {
              'session': 'TESTJSON_04_19_2026',
              'times': [1.27, 1.42, 1.04, 0.97],
            },
          ],
        });

        expect(jsonDecode(jaxFile.readAsStringSync()), {
          'name': 'Jax',
          'sessions': [
            {
              'session': 'TESTJSON_04_19_2026',
              'times': [1.06, 0.97, 1.33],
            },
          ],
        });

        expect(jsonDecode(evanFile.readAsStringSync()), {
          'name': 'Evan',
          'sessions': [
            {
              'session': 'TESTJSON_04_19_2026',
              'times': [0.91, 0.99, 1.21],
            },
          ],
        });
      } finally {
        Directory.current = originalDirectory;
        tempDir.deleteSync(recursive: true);
      }
    },
  );
}


