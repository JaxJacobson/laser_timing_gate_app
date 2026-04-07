import 'dart:async';

import 'package:flutter/material.dart';
import 'BT_HC05.dart';

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

// runs when screen closes
// Disposes of the HC-05 connection and stops the timer to prevent memory leaks.
  @override
  void dispose() {
    refreshTimer?.cancel();
    hc05Service.dispose();
    super.dispose();
  }
}

