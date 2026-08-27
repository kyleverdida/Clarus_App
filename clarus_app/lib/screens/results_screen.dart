import 'package:flutter/material.dart';
import '../models/screening_result.dart';

class ResultsScreen extends StatelessWidget {
  final ScreeningResult result;
  const ResultsScreen({super.key, required this.result});

  Color _triageColor() {
    switch (result.triage) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screening Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _triageColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _triageColor(), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    result.triage.toUpperCase(),
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: _triageColor(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Grad-CAM Visualization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Highlighted regions show what most influenced this prediction. '
              'This does not confirm a diagnosis — final judgment remains with the reviewing clinician.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(result.gradcamUrl, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            Text('Encounter ID: ${result.encounterId}', style: const TextStyle(color: Colors.grey)),
            Text('Timestamp: ${result.timestamp}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Screen Another Image'),
            ),
          ],
        ),
      ),
    );
  }
}
