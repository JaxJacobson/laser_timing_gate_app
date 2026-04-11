import 'dart:io';
import 'package:test/test.dart';
import 'package:laser_timing_gate_app/end_session_sort.dart';

void main() {
  test(
    // This test verifies that the endSessionSort function correctly identifies the first athlete in the start list and creates a txt file for them if it doesn't already exist.
    // The test sets up a temporary directory structure, creates a session file with the appropriate format, and checks that the athlete's file is created after calling endSessionSort.
    'passes when the txt file for the first athlete in the start list is found',
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

        // Create a txt file for the athlete "Mayson" in the 'athletes' directory
        final athleteFile = File('${athletesDir.path}/Mayson.txt')
          ..writeAsStringSync('Existing athlete file');

        // Create a session file in the 'sessions' directory with the appropriate format for endSessionSort
        final sessionFile = File('${sessionsDir.path}/session_name.txt')
          ..writeAsStringSync('test_session\nMayson\n12.34\n');

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
    // This test verifies that the endSessionSort function correctly processes the session file and records all times for the
    // first athlete in the start list into their txt file on separate lines.
    'records all times for the first athlete into their txt file on separate lines',
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

        final athleteFile = File('athletes/Mayson.txt')..createSync();

        // Create a session file with multiple entries for "Mayson" to test that all times are recorded correctly
        final sessionFile = File('sessions/session_name.txt')
          ..writeAsStringSync(
            'test_session\n'
            'Mayson\n'
            '12.34\n'
            'Jax\n'
            '15.67\n'
            'Mayson\n'
            '11.98\n'
            'Evan\n'
            '14.20\n'
            'Mayson\n'
            '12.01\n',
          );

        final startList = ['Mayson', 'Jax', 'Evan'];

        // Call endSessionSort with the session file path and start list
        await endSessionSort(sessionFile.path, startList);

        // Read the lines from the athlete file for "Mayson" to verify that all three times are recorded on separate lines
        final athleteLines = athleteFile.readAsLinesSync();

        // Check that the athlete file for "Mayson" contains all three times recorded on separate lines
        expect(athleteLines, ['test_session','12.34', '11.98', '12.01']);
      } finally {
        Directory.current = originalDirectory;
        tempDir.deleteSync(recursive: true);
      }
    },
  );

  test(
    // This test verifies that the endSessionSort function correctly processes the session file
    // and records the session name first, then all times for all athletes in the start list
    // into their respective txt files on separate lines.
    'records the session name first, then each athlete gets their own times',
    () async {
      // Set up a temporary directory and create the necessary files for the test
      final tempDir = Directory.systemTemp.createTempSync('end_session_sort_test');
      final originalDirectory = Directory.current;

      try {
        // Change the current working directory to the temporary directory for the duration of the test
        Directory.current = tempDir.path;

        Directory('athletes').createSync();
        Directory('sessions').createSync();

        // Create txt files for the athletes "Mayson", "Jax", and "Evan" in the 'athletes' directory
        final maysonFile = File('athletes/Mayson.txt')..createSync();
        final jaxFile = File('athletes/Jax.txt')..createSync();
        final evanFile = File('athletes/Evan.txt')..createSync();

        // Create a session file with multiple entries for "Mayson", "Jax", and "Evan" to test that the
        // session name is written first and that all times are recorded correctly
        final sessionFile = File('sessions/session_name.txt')
          ..writeAsStringSync(
            'test_session\n'
            'Mayson\n'
            '12.34\n'
            'Jax\n'
            '15.67\n'
            'Mayson\n'
            '11.98\n'
            'Evan\n'
            '14.20\n'
            'Jax\n'
            '15.10\n'
            'Evan\n'
            '13.95\n',
          );

        final startList = ['Mayson', 'Jax', 'Evan'];

        // Call endSessionSort with the session file path and start list
        await endSessionSort(sessionFile.path, startList);

        // Check that each athlete file starts with the session name and then contains only that athlete's times
        expect(maysonFile.readAsLinesSync(), ['test_session', '12.34', '11.98']);
        expect(jaxFile.readAsLinesSync(), ['test_session', '15.67', '15.10']);
        expect(evanFile.readAsLinesSync(), ['test_session', '14.20', '13.95']);
      } finally {
        Directory.current = originalDirectory;
        tempDir.deleteSync(recursive: true);
      }
    },
  );
}


