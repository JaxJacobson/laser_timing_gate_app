import 'package:flutter/material.dart';

class AthletePage extends StatefulWidget {
  const AthletePage({super.key});

  @override
  State<AthletePage> createState() => _AthletePageState();
}

class _AthletePageState extends State<AthletePage> {
  static const String title = 'Athlete Info';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 174, 0, 255)),
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
