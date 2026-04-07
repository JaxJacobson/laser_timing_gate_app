import 'dart:convert';

import 'package:flutter_libserialport/flutter_libserialport.dart';

class HC05Service {
  SerialPort? _port;
  SerialPortReader? _reader;

  String latestValue = 'Waiting...';

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
      final value = ascii.decode(data, allowInvalid: true).trim();
      if (value.isNotEmpty) {
        latestValue = value
          .replaceFirst('UM:', '')
          .replaceFirst('N:', '')
          .trim();
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
