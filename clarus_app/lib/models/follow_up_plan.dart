class FollowUpPlan {
  final String followUpId;
  final String? encounterId;
  final String patientId;
  final String contactMethod;
  final String contactValue;
  final DateTime returnDate;
  final String status;

  const FollowUpPlan({
    required this.followUpId,
    required this.encounterId,
    required this.patientId,
    required this.contactMethod,
    required this.contactValue,
    required this.returnDate,
    required this.status,
  });

  factory FollowUpPlan.fromJson(Map<String, dynamic> json) {
    return FollowUpPlan(
      followUpId: json['follow_up_id'] as String,
      encounterId: json['encounter_id'] as String?,
      patientId: json['patient_id'] as String,
      contactMethod: json['contact_method'] as String,
      contactValue: json['contact_value'] as String,
      returnDate: DateTime.parse(json['return_date'] as String),
      status: json['status'] as String,
    );
  }
}
