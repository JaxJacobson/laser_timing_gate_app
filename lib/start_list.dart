import 'package:flutter/material.dart';
import 'file_service.dart';

class StartListPage extends StatefulWidget {
  const StartListPage({super.key});

  @override
  State<StartListPage> createState() => _StartListPageState();
}

class _StartListPageState extends State<StartListPage> {
  static const String title = 'Start List';
  final TextEditingController _controller = TextEditingController();

  String? filename; // Variable to hold the custom file name entered by the user
  String? name;     // Variable to hold the athlete name entered by the user


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 255, 68)),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(title),
        ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Example: Main.txt',
              ),        
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                filename = _controller.text; // Get the custom file name from the text field;
                _controller.clear();
              },
              child: Text('Enter Start List Name'),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Example: Jax',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                name = _controller.text; // Get the athlete name from the text field
                await FileTransfer.saveAthleteToCustomList( // Call the function to save the athlete name to the custom file
                  name: name!,          // Needs the ! for some reason
                  fileName: filename!,  // Needs the ! for some reason
                );
                _controller.clear();
              },
              child: Text('Save Athlete Name to Start List'),
            ),
          ],
        ),
      ),
    ));
  }
}
