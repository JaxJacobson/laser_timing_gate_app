// BT_HC05.dart
// Mayson Ostermeyer 04/07/2026
//
// The file handles the connection to the HC-05 Bluetooth module and
// reads incoming data, updating the latestValue variable accordingly.

// IMPORTS
import 'dart:convert';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class HC05Service {
  // Serial port and reader for HC-05 communication
  SerialPort? _port;
  SerialPortReader? _reader;

  // Latest value received from the HC-05 moduleThe
  String latest_time = 'Waiting...';
  String _buffer = '';

 // Connect to the HC-05 Bluetooth module
  Future<String> connect() async {
    const portName = 'COM5';

    _port = SerialPort(portName);

    if (!_port!.openReadWrite()) {
      return 'Failed to open $portName';
    }
    // Configure the serial port settings
    final config = _port!.config;
    config.baudRate = 9600;
    config.bits = 8;
    config.stopBits = 1;
    config.parity = SerialPortParity.none;
    _port!.config = config;

    // Start reading data from the HC-05 module
    _reader = SerialPortReader(_port!);
    _reader!.stream.listen((data) {

      // Append incoming data to the buffer and process complete lines
      _buffer += ascii.decode(data, allowInvalid: true);

      // Check for complete lines in the buffer
      if (_buffer.contains('\n')) {

        // Split the buffer into lines and process each line
        final parts = _buffer.split('\n');

        // Update latest_time with the most recent time value received
        for (int i = 0; i < parts.length - 1; i++) {
          final time = parts[i]
              .replaceAll('\r', '')
              .trim();

          if (time.isNotEmpty) {
            latest_time = time;
          }
        }
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