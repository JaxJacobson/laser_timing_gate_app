import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'BT_HC05.dart';
import 'running_session.dart';

class StartSessionPage extends StatefulWidget {
  const StartSessionPage({super.key});

  @override
  State<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends State<StartSessionPage> {
  static const String title = 'Current Session';

  final HC05Service hc05Service = HC05Service();
  String latestData = 'Waiting...';
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
        latestData = hc05Service.latestValue;
      });
    });

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: button1,
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
              onPressed: button2,
              child: const Text('Start Session'),
            ),

          ],
        ),
      ),
    );
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


