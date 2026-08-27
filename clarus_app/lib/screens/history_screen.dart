import 'package:flutter/material.dart';

// Placeholder history screen — wire this to a real GET /history endpoint
// once Person B has the database + encounter-record endpoint ready.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data — replace with a FutureBuilder calling the real API later.
    final mockHistory = [
      {'id': 'mock-001', 'triage': 'Normal', 'date': '2026-08-18'},
      {'id': 'mock-002', 'triage': 'Monitor', 'date': '2026-08-19'},
      {'id': 'mock-003', 'triage': 'Refer', 'date': '2026-08-20'},
    ];

    Color colorFor(String triage) {
      switch (triage) {
        case 'Normal':
          return Colors.green;
        case 'Monitor':
          return Colors.orange;
        case 'Refer':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Screening History')),
      body: ListView.builder(
        itemCount: mockHistory.length,
        itemBuilder: (context, index) {
          final item = mockHistory[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: colorFor(item['triage']!)),
            title: Text('Encounter ${item['id']}'),
            subtitle: Text(item['date']!),
            trailing: Text(item['triage']!),
          );
        },
      ),
    );
  }
}
