import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../theme/app_theme.dart';

class PastResultScreen extends StatelessWidget {
  final HistoryEntry result;
  final String? patientId;

  const PastResultScreen({super.key, required this.result, this.patientId});

  @override
  Widget build(BuildContext context) {
    final triage = result.triage ?? 'Unknown';
    final triageColor = ClarusColors.forTriage(triage);

    return Scaffold(
      appBar: AppBar(title: const Text('Past screening result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ClarusColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ClarusColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRIAGE RESULT',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    triage,
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(color: triageColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confidence ${(result.confidence * 100).toStringAsFixed(1)}%',
                    style: ClarusType.mono(
                      size: 14,
                      color: ClarusColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Screening details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Patient',
              value: patientId ?? result.patientId ?? 'Not recorded',
            ),
            _DetailRow(label: 'Worker', value: result.workerName),
            _DetailRow(label: 'Encounter', value: result.encounterId),
            _DetailRow(label: 'Screened', value: result.timestamp),
            const SizedBox(height: 24),
            Text(
              'Grad-CAM visualization',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (result.gradcamUrl == null)
              const _ImagePlaceholder()
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  result.gradcamUrl!,
                  height: 260,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 260,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const _ImagePlaceholder(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ClarusColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClarusColors.divider),
      ),
      child: const Text('Visualization unavailable'),
    );
  }
}
