import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/screening_result.dart';
import '../models/history_entry.dart';
import '../models/follow_up_plan.dart';

const bool useMockApi = false;
const String baseUrl = 'http://10.0.2.2:8000';

class ApiService {
  Future<ScreeningResult> uploadImage(
    File imageFile,
    String workerName,
    String patientId,
  ) async {
    if (useMockApi) {
      return _mockUpload();
    }
    return _realUpload(imageFile, workerName, patientId);
  }

  Future<List<HistoryEntry>> fetchHistory() async {
    if (useMockApi) {
      return _mockHistory();
    }
    return _realHistory();
  }

  Future<FollowUpPlan> createFollowUpPlan({
    required String patientId,
    required String? encounterId,
    required String contactMethod,
    required String contactValue,
    required bool consentGiven,
    required DateTime returnDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/follow-ups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'patient_id': patientId,
        'encounter_id': encounterId,
        'contact_method': contactMethod,
        'contact_value': contactValue,
        'consent_given': consentGiven,
        'return_date': returnDate.toIso8601String().split('T').first,
      }),
    );

    if (response.statusCode == 201) {
      return FollowUpPlan.fromJson(jsonDecode(response.body));
    }
    throw Exception(
      'Failed to save follow-up plan: ${response.statusCode} ${response.body}',
    );
  }

  Future<List<FollowUpPlan>> fetchFollowUpPlans() async {
    final response = await http.get(Uri.parse('$baseUrl/follow-ups'));
    if (response.statusCode == 200) {
      final List<dynamic> rawList = jsonDecode(response.body);
      return rawList.map((item) => FollowUpPlan.fromJson(item)).toList();
    }
    throw Exception('Failed to load monitoring plans: ${response.statusCode}');
  }

  Future<FollowUpPlan> updateFollowUpPlan(
    String followUpId,
    Map<String, dynamic> updates,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/follow-ups/$followUpId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
    if (response.statusCode == 200) {
      return FollowUpPlan.fromJson(jsonDecode(response.body));
    }
    throw Exception(
      'Failed to update follow-up plan: ${response.statusCode} ${response.body}',
    );
  }

  static int _mockCallCount = 0;

  Future<ScreeningResult> _mockUpload() async {
    await Future.delayed(const Duration(seconds: 2));
    final outcomes = [
      {
        'quality_pass': true,
        'triage': 'Normal',
        'confidence': 0.94,
        'gradcam_url':
            'https://placehold.co/400x400/22c55e/white/png?text=Normal',
        'encounter_id': 'mock-001',
        'patient_id': 'mock-patient-001',
      },
      {
        'quality_pass': true,
        'triage': 'Monitor',
        'confidence': 0.78,
        'gradcam_url':
            'https://placehold.co/400x400/eab308/white/png?text=Monitor',
        'encounter_id': 'mock-002',
        'patient_id': 'mock-patient-002',
      },
      {
        'quality_pass': true,
        'triage': 'Refer',
        'confidence': 0.91,
        'gradcam_url':
            'https://placehold.co/400x400/ef4444/white/png?text=Refer',
        'encounter_id': 'mock-003',
        'patient_id': 'mock-patient-003',
      },
    ];
    final next = outcomes[_mockCallCount % outcomes.length];
    _mockCallCount++;
    return ScreeningResult.fromJson(next);
  }

  Future<List<HistoryEntry>> _mockHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      HistoryEntry(
        encounterId: 'mock-001',
        patientId: 'mock-patient-001',
        workerName: 'Nurse Reyes',
        triage: 'Normal',
        confidence: 0.94,
        gradcamUrl: null,
        timestamp: DateTime.now().toIso8601String(),
      ),
      HistoryEntry(
        encounterId: 'mock-002',
        patientId: 'mock-patient-002',
        workerName: 'Nurse Reyes',
        triage: 'Monitor',
        confidence: 0.78,
        gradcamUrl: null,
        timestamp: DateTime.now().toIso8601String(),
      ),
    ];
  }

  // ---- REAL: now correctly sends worker_name as a form field ----
  Future<ScreeningResult> _realUpload(
    File imageFile,
    String workerName,
    String patientId,
  ) async {
    final uri = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );
    request.fields['worker_name'] =
        workerName; // <-- this line was missing entirely
    request.fields['patient_id'] = patientId;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ScreeningResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<HistoryEntry>> _realHistory() async {
    final uri = Uri.parse('$baseUrl/history');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> rawList = jsonDecode(response.body);
      return rawList.map((item) => HistoryEntry.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load history: ${response.statusCode}');
    }
  }
}
