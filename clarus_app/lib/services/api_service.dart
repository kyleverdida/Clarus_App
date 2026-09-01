import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/screening_result.dart';
import '../models/history_entry.dart';

const bool useMockApi = false;
const String baseUrl = 'http://10.0.2.2:8000';

class ApiService {
  Future<ScreeningResult> uploadImage(File imageFile, String workerName) async {
    if (useMockApi) {
      return _mockUpload();
    }
    return _realUpload(imageFile, workerName);
  }

  Future<List<HistoryEntry>> fetchHistory() async {
    if (useMockApi) {
      return _mockHistory();
    }
    return _realHistory();
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
        'encounter_id': 'mock-001'
      },
      {
        'quality_pass': true,
        'triage': 'Monitor',
        'confidence': 0.78,
        'gradcam_url':
            'https://placehold.co/400x400/eab308/white/png?text=Monitor',
        'encounter_id': 'mock-002'
      },
      {
        'quality_pass': true,
        'triage': 'Refer',
        'confidence': 0.91,
        'gradcam_url':
            'https://placehold.co/400x400/ef4444/white/png?text=Refer',
        'encounter_id': 'mock-003'
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
          workerName: 'Nurse Reyes',
          triage: 'Normal',
          confidence: 0.94,
          gradcamUrl: null,
          timestamp: DateTime.now().toIso8601String()),
      HistoryEntry(
          encounterId: 'mock-002',
          workerName: 'Nurse Reyes',
          triage: 'Monitor',
          confidence: 0.78,
          gradcamUrl: null,
          timestamp: DateTime.now().toIso8601String()),
    ];
  }

  // ---- REAL: now correctly sends worker_name as a form field ----
  Future<ScreeningResult> _realUpload(File imageFile, String workerName) async {
    final uri = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['worker_name'] =
        workerName; // <-- this line was missing entirely

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
