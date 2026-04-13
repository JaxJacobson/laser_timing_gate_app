import 'dart:io';
import 'package:test/test.dart';
import 'package:laser_timing_gate_app/file_service.dart';

void main() {
  test(
    'start list input is saved to start_lists directory',
  () async {

    final testName = 'Jax';
    final basePath = Directory.current.path;
    final filePath = '$basePath/start_lists/athletes.txt';

    // Call your function
    await FileService.saveAthleteToStartList(testName);

    final file = File(filePath);

    expect(await file.exists(), true);

    final contents = await file.readAsString();
    expect(contents.contains(testName), true);
  });
}