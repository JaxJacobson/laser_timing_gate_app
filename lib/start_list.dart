import 'package:flutter/material.dart';

class StartListPage extends StatefulWidget {
  const StartListPage({super.key});

  @override
  State<StartListPage> createState() => _StartListPageState();
}

class _StartListPageState extends State<StartListPage> {
  static const String title = 'Start List';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 255, 68)),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(title),
        ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Athlete Name',
              ),
            ),

          ],
        ),
      ),
    ));
  }
}
