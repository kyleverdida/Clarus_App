import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'upload_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  final String workerName;
  final String role;
  const HomeScreen({super.key, required this.workerName, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $workerName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Screening history',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(role, style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's screenings",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Row(
              children: [
                _StatCard(
                    label: 'Normal', value: '3', color: ClarusColors.normal),
                SizedBox(width: 10),
                _StatCard(
                    label: 'Monitor', value: '1', color: ClarusColors.accent),
                SizedBox(width: 10),
                _StatCard(
                    label: 'Refer', value: '1', color: ClarusColors.refer),
              ],
            ),
            const SizedBox(height: 36),
            // Primary call to action — the dashboard's one job is to get
            // the worker into a new screening as fast as possible.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UploadScreen(workerName: workerName)),
                ),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('New screening'),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ClarusColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ClarusColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: ClarusColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Clarus supports initial screening only. Final diagnosis and '
                      'referral decisions remain with a licensed ophthalmologist.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ClarusColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ClarusColors.divider),
        ),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: color, fontSize: 26)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
