// BT_HC05.dart
// Mayson Ostermeyer 04/07/2026
//
// The file handles the connection to the HC-05 Bluetooth module and
// reads incoming data, updating the latestValue variable accordingly.

// IMPORTS
import 'dart:convert';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class HC05Service {
  // Defines the class responsible for managing the connection to the HC-05 Bluetooth module

  // Serial port and reader for HC-05 communication
  SerialPort? _port;
  SerialPortReader? _reader;

  // Latest value received from the HC-05 module
  String latest_time = 'Waiting...';

  // Serial data comes in pieces, so we use a buffer to accumulate data until we have complete lines to process
  String _buffer = '';

 // Connect to the HC-05 Bluetooth module
  Future<String> connect() async {

    // Specify the COM port name for the HC-05 module
    // Mayson PC = 'COM5',Jax PC = 'COM7'
    const portName = 'COM7';


    _port = SerialPort(portName);

    // Attempt to open the serial port for reading and writing
    if (!_port!.openReadWrite()) {

      // If the port fails to open, return an error message
      return 'Failed to open $portName';
    }
    // Serial port settings
    final config = _port!.config;
    config.baudRate = 9600;
    config.bits = 8;
    config.stopBits = 1;
    config.parity = SerialPortParity.none;

    // Turn checking for errors off, as the HC-05 module may not send parity or stop bits in a way that matches the serial port's expectations
    _port!.config = config;

    _reader = SerialPortReader(_port!);

    // Start reading data from the HC-05 module
    // This listens for incoming data continuously and only stops when the connection is closed or an error occurs
    // It loops through this code every time new data is received
    _reader!.stream.listen((data) {

      // Append incoming data to the buffer and process complete lines
      _buffer += ascii.decode(data, allowInvalid: true);

      // Check for complete lines in the buffer, if so, a time value has been received and we can update latest_time
      if (_buffer.contains('\n')) {

        // Split the buffer into lines and process each line
        final parts = _buffer.split('\n');

        // Theoretically, at most there is one complete line, so that must be the time.
        // It can be assumed impossible that two people can run through the gate in less than 0.1 seconds
        // If two people where to be that fast! The laser would not be able to detect them, therefore the app would not matter.... SAD
        final time = parts[0]
            .replaceAll('\r', '')
            .trim();

        if (time.isNotEmpty) {
           latest_time = time;
        }
        
        // This is the remaining part of the buffer.
        // It would be rare that this would ever contain any data.
        // Honestly, it is more likely that Marcus Gubanyi would beat me in a foot race than for this section of code to ever be used.
        // but it is good practice... so I will leave it here to rot in the codebase for all eternity.
        _buffer = parts.last;
      }
    });
    // Return a success message upon successful connection
    return 'Connected to $portName';
  }
// Clean up resources when done
  void dispose() {
    _reader?.close();
    _port?.close();

    _port?.close();
    _port = null;
  }
}