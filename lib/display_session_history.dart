import 'package:flutter/material.dart';

class DisplaySessiosHistoryPage extends StatelessWidget {
  final String sessionPath;

  const DisplaySessiosHistoryPage({
    super.key,
    required this.sessionPath,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = sessionPath.split('\\').last;
    final displayName = fileName.replaceFirst(RegExp(r'\.txt$'), '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
      ),
      body: Center(
        child: Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
