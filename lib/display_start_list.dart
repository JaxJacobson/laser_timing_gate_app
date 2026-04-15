import 'package:flutter/material.dart';

class DisplayStartListPage extends StatelessWidget {
  final String startListPath;

  const DisplayStartListPage({
    super.key,
    required this.startListPath,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = startListPath.split('\\').last;
    final displayName = fileName.replaceFirst(RegExp(r'\.txt$'), '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start List Details'),
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
