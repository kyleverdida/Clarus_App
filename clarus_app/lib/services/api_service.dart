import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/screening_result.dart';

/// Toggle this to false once Person B's real backend endpoint is ready.
/// Keep working against mock data until then — never block on the backend.
const bool useMockApi = true;

/// Change this once you know the real deployed backend URL.
const String baseUrl =
    'http://10.0.2.2:8000'; // 10.0.2.2 = localhost for Android emulator

class ApiService {
  Future<ScreeningResult> uploadImage(File imageFile) async {
    if (useMockApi) {
      return _mockUpload();
    }
    return _realUpload(imageFile);
  }

  // ---- MOCK: lets you build and demo the whole app before the backend exists ----
  Future<ScreeningResult> _mockUpload() async {
    await Future.delayed(const Duration(seconds: 2)); // simulate network delay

    // Rotate through a few fake outcomes so you can test all UI states
    final outcomes = [
      {
        'quality_pass': true,
        'triage': 'Normal',
        'confidence': 0.94,
        'gradcam_url': 'https://placehold.co/400x400/22c55e/white?text=Normal',
        'encounter_id': 'mock-001',
      },
      {
        'quality_pass': true,
        'triage': 'Monitor',
        'confidence': 0.78,
        'gradcam_url': 'https://placehold.co/400x400/eab308/white?text=Monitor',
        'encounter_id': 'mock-002',
      },
      {
        'quality_pass': true,
        'triage': 'Refer',
        'confidence': 0.91,
        'gradcam_url': 'https://placehold.co/400x400/ef4444/white?text=Refer',
        'encounter_id': 'mock-003',
      },
    ];
    final random = outcomes[DateTime.now().second % outcomes.length];
    return ScreeningResult.fromJson(random);
  }

  // ---- REAL: swap in once Person B's endpoint is live ----
  Future<ScreeningResult> _realUpload(File imageFile) async {
    final uri = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ScreeningResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }
  }
}
