// BT_HC05.dart
// Mayson Ostermeyer 04/07/2026
//
// The file handles the connection to the HC-05 Bluetooth module and
// reads incoming data, updating the latestValue variable accordingly.

// IMPORTS
import 'dart:convert';
import 'package:flutter_libserialport/flutter_libserialport.dart';


class HC05Service {
  // Serial port and reader for handling Bluetooth communication.

  SerialPort? _port;
  SerialPortReader? _reader;

  String latestValue = 'Waiting...';

  Future<String> connect() async {
    // Attempt to connect to the HC-05 Bluetooth module on the specified COM port.

    const portName = 'COM5';
    // Initialize the serial port with the given port name.
    _port = SerialPort(portName);

    if (!_port!.openReadWrite()) {
      return 'Failed to open $portName';
    }

    // Configure the serial port settings for communication with the HC-05 module.
    final config = _port!.config;
    config.baudRate = 9600;
    config.bits = 8;
    config.stopBits = 1;
    config.parity = SerialPortParity.none;
    _port!.config = config;

    // Set up a reader to listen for incoming data from the HC-05 module.
    _reader = SerialPortReader(_port!);
    _reader!.stream.listen((data) {
      final value = ascii.decode(data, allowInvalid: true).trim();
      if (value.isNotEmpty) {
        latestValue = value
          .replaceFirst('UM:', '')
          .replaceFirst('N:', '')
          .trim();
      }
    });
    // Return a success message indicating the connection was established.
    return 'Connected to $portName';
  }

// Closes the serial port and reader when done.
  void dispose() {
    _reader?.close();
    _port?.close();

    _port?.close();
    _port = null;
  }
}