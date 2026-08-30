import 'package:flutter/material.dart';
import '../models/screening_result.dart';
import '../theme/app_theme.dart';

class ResultsScreen extends StatelessWidget {
  final ScreeningResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // This screen is only ever navigated to when qualityPass was true,
    // so triage/gradcamUrl/encounterId are guaranteed non-null in practice —
    // but the fallbacks below keep the UI safe even if that assumption
    // is ever violated by a future change upstream.
    final triageText = result.triage ?? 'Unknown';
    final color = ClarusColors.forTriage(triageText);

    return Scaffold(
      appBar: AppBar(title: const Text('Screening Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: ClarusColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ClarusColors.divider),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                        width: 6,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16)),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TRIAGE RESULT',
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            Text(triageText,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(color: color)),
                            const SizedBox(height: 8),
                            Text(
                                'Confidence ${(result.confidence * 100).toStringAsFixed(1)}%',
                                style: ClarusType.mono(
                                    size: 14, color: ClarusColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Grad-CAM visualization',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Highlighted regions show what most influenced this prediction. '
              'This does not confirm a diagnosis — final judgment remains with the reviewing clinician.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            if (result.gradcamUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  result.gradcamUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: ClarusColors.canvas,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                color: ClarusColors.textMuted),
                            SizedBox(height: 8),
                            Text('Visualization could not be loaded'),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: ClarusColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ClarusColors.divider),
                ),
                child: const Center(child: Text('Visualization unavailable')),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ClarusColors.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ClarusColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Encounter ${result.encounterId ?? 'N/A'}',
                      style: ClarusType.mono(size: 13)),
                  const SizedBox(height: 4),
                  Text('${result.timestamp}', style: ClarusType.mono(size: 13)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Screen another image'),
            ),
          ],
        ),
      ),
    );
  }
}
