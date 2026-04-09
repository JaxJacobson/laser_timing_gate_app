import 'dart:convert';

import 'package:flutter_libserialport/flutter_libserialport.dart';

class HC05Service {
  SerialPort? _port;
  SerialPortReader? _reader;

  String latestValue = 'Waiting...';
  String _buffer = '';

  Future<String> connect() async {
    const portName = 'COM5';

    _port = SerialPort(portName);

    if (!_port!.openReadWrite()) {
      return 'Failed to open $portName';
    }

    final config = _port!.config;
    config.baudRate = 9600;
    config.bits = 8;
    config.stopBits = 1;
    config.parity = SerialPortParity.none;
    _port!.config = config;

    _reader = SerialPortReader(_port!);
    _reader!.stream.listen((data) {
      _buffer += ascii.decode(data, allowInvalid: true);

      if (_buffer.contains('\n')) {
        final parts = _buffer.split('\n');

        for (int i = 0; i < parts.length - 1; i++) {
          final value = parts[i]
              .replaceAll('\r', '')
              .trim();

          if (value.isNotEmpty) {
            latestValue = value;
          }
        }

        _buffer = parts.last;
      }
    });

    return 'Connected to $portName';
  }

  void dispose() {
    _reader?.close();
    _port?.close();

    _port?.close();
    _port = null;
  }
}