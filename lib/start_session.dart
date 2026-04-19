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
  const StartSessionPage({super.key});

  @override
  State<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends State<StartSessionPage> {
  static const String title = 'Current Session';

  final HC05Service hc05Service = HC05Service();
  String latestData = 'Waiting...';
  Timer? refreshTimer; // Timer to periodically refresh data from HC-05
  String? selectedListName;
  List<String> startListFiles = [];
  final TextEditingController sessionNameController = TextEditingController();
  String session_name = '';

  void loadStartLists() {
    final directory = Directory('start_lists');

    if (directory.existsSync()) { // Check if the directory exists
      final files = directory
          .listSync() // List all files in the directory
          .whereType<File>() // Filter to only include files (not directories)
          .where((file) => file.path.endsWith('.txt')) // Filter to only include .txt files
          .map((file) => file.uri.pathSegments.last) // Extract just the file name from the path
          .toList(); // Convert to a list

      setState(() {
        startListFiles = files;
      });
    }
  }

  Future<void> connectButton() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting...'),
        duration: Duration(seconds: 1),
      ),
    );

    final result = await hc05Service.connect();

    // Prevents crashing if user exits mid-connection
    if (!mounted) return;

    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        latestData = hc05Service.latest_time;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

void startButton() async {
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
  final sessionFile = File('sessions/$fullFileName.json');

  if (!sessionFile.existsSync()) {
    sessionFile.createSync(recursive: true);
  }

  final sessionJson = {
    'session': fullFileName,
    'athletes': <Map<String, dynamic>>[],
  };

  sessionFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(sessionJson),
  );

  if (!mounted) return;


  final file = File('start_lists/$selectedListName');
  final OGstartList = file
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty)
      .toList();
  final startList = List<String>.from(OGstartList);

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

  @override
  void initState() {
    super.initState();
    loadStartLists();
  }

Widget create(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 166, 255, 0)),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(title),
        ),
      ));
  }
  @override
  Widget build(BuildContext context) {
    return Theme( // Everything can have a theme, title and background
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
            ElevatedButton(
              onPressed: connectButton,
              child: const Text('Connect to HC-05'),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedListName,
              hint: const Text('Select List'),
              items: startListFiles.map((fileName) {
                return DropdownMenuItem<String>(
                  value: fileName,
                  child: Text(fileName),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedListName = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: sessionNameController,
              onChanged: (value) {
                setState(() {
                  session_name = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Session Name',
              ),
            ),
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


