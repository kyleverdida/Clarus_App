// Matches the API contract agreed with Person B (backend):
// POST /predict
//   in: image file
//   out (quality passed): { quality_pass: true, triage, confidence, gradcam_url, encounter_id }
//   out (quality FAILED):  { quality_pass: false, triage: null, confidence: 0.0,
//                            gradcam_url: null, encounter_id: null, quality_reason: "..." }
//
// triage / gradcamUrl / encounterId are nullable because the backend sends
// null for all three when an image fails the quality check — the model
// must be able to represent that case, not just the success case.

class ScreeningResult {
  final bool qualityPass;
  final String?
      triage; // "Normal" | "Monitor" | "Refer" | null if quality failed
  final double confidence;
  final String? gradcamUrl;
  final String? encounterId;
  final String?
      qualityReason; // e.g. "blurry", "too_dark" — present only on failure
  final DateTime timestamp;

  ScreeningResult({
    required this.qualityPass,
    required this.triage,
    required this.confidence,
    required this.gradcamUrl,
    required this.encounterId,
    this.qualityReason,
    required this.timestamp,
  });

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    return ScreeningResult(
      qualityPass: json['quality_pass'] as bool,
      triage: json['triage'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      gradcamUrl: json['gradcam_url'] as String?,
      encounterId: json['encounter_id'] as String?,
      qualityReason: json['quality_reason'] as String?,
      timestamp: DateTime.now(),
    );
  }
}
