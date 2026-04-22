import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class DisplayStartListPage extends StatefulWidget {
  final String startListPath;

  const DisplayStartListPage({
    super.key,
    required this.startListPath,
  });

  @override
  State<DisplayStartListPage> createState() => _DisplayStartListPageState();
}

class _DisplayStartListPageState extends State<DisplayStartListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionsAndOpen(); // Show instructions page before txt file.
    });
  }

  Future<void> _showInstructionsAndOpen() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,  // User must tap button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Instructions'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('One name per line, no commas or other separators.',
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 0), fontSize: 16),
                ),
                const SizedBox(height: 25),
                const Text('Example format:'),
                const SizedBox(height: 25),
                const Text(
                  'Mayson\nJax\nEvan\nTrey\n',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                const Text('To save, press ctrl+s or click save in the file menu and close the file.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green, fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openFile();  // The txt file will open after the "Open File" button is pressed.
              },
              child: const Text('Open File'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFile() async {
    final result = await OpenFile.open(widget.startListPath);
    if (mounted) {
      if (result.type != ResultType.done) { // If the file fails to open, show a snackbar with the error message.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: ${result.message}')),
        );
      }
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start List'),
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Show a loading indicator while the file is being opened.        
      ),
    );
  }
}
