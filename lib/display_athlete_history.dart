import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laser_timing_gate_app/session_history.dart';

class AthleteHistoryResult {
  const AthleteHistoryResult({
    required this.name,
    required this.time,
  });

  final String name;
  final String time;
}

class DisplayAthleteHistoryPage extends StatelessWidget {
  final String athletePath;

  const DisplayAthleteHistoryPage({
    super.key,
    required this.athletePath,
  });

    List<AthleteHistoryResult> loadResults() {
      final sessionFile = File(athletePath);

      if (!sessionFile.existsSync()) {
        return [];
      }

      final raw = sessionFile.readAsStringSync();
      final Map<String, dynamic> sessionData = jsonDecode(raw);
      final List<dynamic> sessions = sessionData['sessions'] ?? [];

      final List<AthleteHistoryResult> results = [];
      int maxTimes = 0;

      for (final session in sessions) {
        final List<dynamic> times = session['times'] ?? [];
        if (times.length > maxTimes) {
          maxTimes = times.length;
        }
      }

      for (int timeIndex = 0; timeIndex < maxTimes; timeIndex++) {
        for (final session in sessions) {
          final String name = session['session'] ?? '';
          final List<dynamic> times = session['times'] ?? [];

          if (timeIndex < times.length) {
            final value = times[timeIndex];
            final displayTime = (value is num)
                ? value.toStringAsFixed(2)
                : value.toString();

            results.add(
              AthleteHistoryResult(
                name: name,
                time: displayTime,
              ),
            );
          }
        }
      }

      return results.reversed.toList();
    }


  @override
  Widget build(BuildContext context) {
    final fileName = athletePath.split('\\').last;
    final displayName = fileName.replaceFirst(RegExp(r'\.json$'), '');
    final results = loadResults();

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: results.isEmpty
              ? const Center(
                  child: Text(
                    'No times recorded for this session',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            result.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final dashCount =
                                    (constraints.maxWidth / 8).floor();

                                return Text(
                                  '${'-' * dashCount}${result.time}',
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(fontSize: 18),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

}