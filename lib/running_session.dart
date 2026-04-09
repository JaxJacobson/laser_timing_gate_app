import 'package:flutter/material.dart';

class RunningSessionPage extends StatelessWidget {
  final String sessionName;
  final String startListName;

  const RunningSessionPage({
    super.key,
    required this.sessionName,
    required this.startListName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session: $sessionName'),
            const SizedBox(height: 12),
            Text('Start List: $startListName'),
          ],
        ),
      ),
    );
  }
}


