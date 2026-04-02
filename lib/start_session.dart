/*

import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Timing Gate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 106, 0)),
      ),
      home: const MyHomePage(title: 'Laser Timing Gate')
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // button1 is for the starting a session page
  void button1() {
    ScaffoldMessenger.of(context).showSnackBar(
      // The SnackBar only displays a message for 3 seconds.
        const SnackBar(
          content: Text('Starting a session...'),
          duration: Duration(seconds: 2),
        ),
      );
      // After message is shown, the Session Page will pop up.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Session Page')),
    );
    
  }
  void button2() {
    ScaffoldMessenger.of(context).showSnackBar(
      // The SnackBar only displays a message for 3 seconds.
        const SnackBar(
          content: Text('Showing session history...'),
          duration: Duration(seconds: 2),
        ),
      );
      // After message is shown, the Session History Page will pop up.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Session History Page')),
    );
  }
void button3() {
    ScaffoldMessenger.of(context).showSnackBar(
      // The SnackBar only displays a message for 3 seconds.
        const SnackBar(
          content: Text('Showing athlete information...'),
          duration: Duration(seconds: 2),
        ),
      );
      // After message is shown, the Athlete Information Page will pop up.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Athlete Information Page')),
    );
  }
  void button4() {
    ScaffoldMessenger.of(context).showSnackBar(
      // The SnackBar only displays a message for 3 seconds.
        const SnackBar(
          content: Text('Showing start list...'),
          duration: Duration(seconds: 2),
        ),
      );
      // After message is shown, the Start List Page will pop up.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Start List Page')),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
 
        title: Text(widget.title),
        ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // When pressed, the button will call the "snackbar" which will display a message.
            // The SnackBar is at the top of the MyHomePageState class.
            ElevatedButton(onPressed: button1, child: const Text('Start Session')),
            ElevatedButton(onPressed: button2, child: const Text('Session History')),
            ElevatedButton(onPressed: button3, child: const Text('Athletes')),
            ElevatedButton(onPressed: button4, child: const Text('Start List'))


            // Button needs to be a direct part of scaffold, cannot be a child of body if FAB.
            // Its default position is bottom right of screen.
            // In order for it to be centered with text, it has to be an ElevatedButton in the body
          ],
        ),
      ),
    );
  }
}
*/