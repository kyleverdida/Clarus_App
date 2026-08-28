import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Placeholder history screen — wire this to a real GET /history endpoint
// once Person B has the database + encounter-record endpoint ready.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockHistory = [
      {'id': 'mock-001', 'triage': 'Normal', 'date': 'Aug 18, 2026'},
      {'id': 'mock-002', 'triage': 'Monitor', 'date': 'Aug 19, 2026'},
      {'id': 'mock-003', 'triage': 'Refer', 'date': 'Aug 20, 2026'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Screening History')),
      body: mockHistory.isEmpty
          ? Center(
              child: Text('No screenings yet — start one from the Screen tab.',
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = mockHistory[index];
                final color = ClarusColors.forTriage(item['triage']!);
                return Container(
                  decoration: BoxDecoration(
                    color: ClarusColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ClarusColors.divider),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                            width: 5,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(14)),
                            )),
                        Expanded(
                          child: ListTile(
                            title: Text('Encounter ${item['id']}',
                                style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(item['date']!,
                                style: ClarusType.mono(size: 12)),
                            trailing: Text(item['triage']!,
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
