/// Matches the raw row shape returned by GET /history — these are the
/// actual database columns from app/database.py, not the same shape as
/// ScreeningResult (which is specifically the /predict response).
class HistoryEntry {
  final String encounterId;
  final String workerName;
  final String? triage; // nullable defensively, even though only
  // successful (quality-passed) encounters are
  // ever saved to the database right now
  final double confidence;
  final String? gradcamUrl;
  final String timestamp;

  HistoryEntry({
    required this.encounterId,
    required this.workerName,
    required this.triage,
    required this.confidence,
    required this.gradcamUrl,
    required this.timestamp,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      encounterId: json['encounter_id'] as String,
      workerName: json['worker_name'] as String? ?? 'Unknown',
      triage: json['triage'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      gradcamUrl: json['gradcam_url'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }
}
