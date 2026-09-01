import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class UploadScreen extends StatefulWidget {
  final String workerName;
  const UploadScreen({super.key, required this.workerName});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitImage() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      final result =
          await _apiService.uploadImage(_selectedImage!, widget.workerName);
      if (!mounted) return;

      if (!result.qualityPass) {
        _showQualityWarning(result.qualityReason);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  /// Shows a specific, actionable message based on why the image failed
  /// quality gating, rather than one generic warning for every case.
  void _showQualityWarning(String? reason) {
    final message = switch (reason) {
      'blurry' => 'This image appears too blurry to analyze reliably. '
          'Hold the camera steady and ensure the lens is focused, then recapture.',
      'too_dark' => 'This image is too dark to analyze reliably. '
          'Check the lighting or lens illumination, then recapture.',
      'overexposed' => 'This image is overexposed. '
          'Reduce the light source intensity, then recapture.',
      'unreadable_file' => 'This file could not be read as an image. '
          'Try capturing or selecting a different file.',
      _ =>
        'This image did not meet the minimum quality threshold. Please recapture.',
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Image quality insufficient'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Recapture'),
          ),
        ],
      ),
    );
  }

  /// The signature element: a circular iris-styled viewfinder instead of
  /// a generic rectangular photo box. Frames the eye and ties the visual
  /// identity to the app's subject and name.
  Widget _buildViewfinder() {
    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [ClarusColors.ink, ClarusColors.accent, ClarusColors.ink],
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: ClarusColors.canvas),
        padding: const EdgeInsets.all(6),
        child: ClipOval(
          child: Container(
            color: ClarusColors.cardSurface,
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_red_eye_outlined,
                          size: 48, color: ClarusColors.textMuted),
                      const SizedBox(height: 10),
                      Text('Center the fundus image',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center),
                    ],
                  )
                : Image.file(_selectedImage!, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Screening')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: _buildViewfinder()),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: const Text('Capture'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 20),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedImage == null || _isUploading
                    ? null
                    : _submitImage,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Analyze image'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Images are checked for quality before classification.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
