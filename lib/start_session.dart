// start_session.dart
// Mayson Ostermeyer 04/07/2026
//
// TODO: write file desciption

// IMPORTS
import 'dart:async';

import 'package:flutter/material.dart';
import 'BT_HC05.dart';
import 'running_session.dart';

class StartSessionPage extends StatefulWidget {
  // Main page for starting a session and connecting to the HC-05 Bluetooth module.
  const StartSessionPage({super.key});
  @override
  State<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends State<StartSessionPage> {
  static const String title = 'Current Session';

 // Initialize the HC-05 service and variables for storing the latest data and timer.
  final HC05Service hc05Service = HC05Service();
  String time = 'Waiting...';
  // Timer for periodically refreshing the displayed data from the HC-05 module.
  Timer? refreshTimer;
  String? selectedListName;
  List<String> startListFiles = [];
  final TextEditingController sessionNameController = TextEditingController();
  String session_name = '';

  void loadStartLists() {
    final directory = Directory('start_lists');

    if (directory.existsSync()) {
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.txt'))
          .map((file) => file.uri.pathSegments.last)
          .toList();

      setState(() {
        startListFiles = files;
      });
    }
  }

  Future<void> button1() async {
    // Handles the button press to connect to the HC-05 module and start receiving data.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Attempt to connect to the HC-05 module and await the result.
    final result = await hc05Service.connect();

    // Prevents crashing if user exits mid-connection
    if (!mounted) return;

    // Set up a timer to periodically refresh the displayed data from the HC-05 module.
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update the time variable with the latest value from the HC-05 service and refresh the UI.
      if (!mounted) return;
      setState(() {
        time = hc05Service.latestValue;
      });
    });
    // Show a SnackBar with the result of the connection attempt (success or failure).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

void button2() async {
  final baseName = session_name.trim();

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

  final now = DateTime.now();
  final dateSuffix =
      '${now.month.toString().padLeft(2, '0')}_'
      '${now.day.toString().padLeft(2, '0')}_'
      '${now.year}';

  final fullFileName = '${baseName}_$dateSuffix';
  final file = File('sessions/$fullFileName.txt');

  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }

  file.writeAsStringSync('Session: $fullFileName\n');

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RunningSessionPage(
        sessionName: fullFileName,
        startListName: selectedListName!,
      ),
    ),
  );
}

  @override
  void initState() {
    super.initState();
    loadStartLists();
  }


  @override
  // Builds the UI for the StartSessionPage, including a button to connect to the HC-05 module and a container to display the latest data.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to initiate connection to the HC-05 Bluetooth module.
            ElevatedButton(
              onPressed: button1,
              child: const Text('Connect to HC-05'),
            ),
            const SizedBox(height: 20),
            Container(
              width: 220,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                latestData,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          ],
        ),
      ),
    );
  }

// Runs when screen closes
// Disposes of the HC-05 connection and stops the timer to prevent memory leaks.
  @override
  void dispose() {
    refreshTimer?.cancel();
    hc05Service.dispose();
    super.dispose();
  }
}

