// Matches the API contract agreed with Person B (backend):
// POST /predict
//   in: image file
//   out: { quality_pass, triage, confidence, gradcam_url, encounter_id }

class ScreeningResult {
  final bool qualityPass;
  final String triage; // "Normal" | "Monitor" | "Refer"
  final double confidence;
  final String gradcamUrl;
  final String encounterId;
  final DateTime timestamp;

  ScreeningResult({
    required this.qualityPass,
    required this.triage,
    required this.confidence,
    required this.gradcamUrl,
    required this.encounterId,
    required this.timestamp,
  });

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    return ScreeningResult(
      qualityPass: json['quality_pass'] as bool,
      triage: json['triage'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      gradcamUrl: json['gradcam_url'] as String,
      encounterId: json['encounter_id'] as String,
      timestamp: DateTime.now(),
    );
  }
}
