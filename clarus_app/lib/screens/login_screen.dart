import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Lightweight identification, not full authentication — enough to attach
/// a worker name to encounter records, matching the multi-user framing
/// in Chapter 1 ("assist healthcare workers and physicians").
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  String _role = 'Health Worker';

  void _continue() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your name to continue')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HomeScreen(workerName: _nameController.text.trim(), role: _role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wordmark, styled with the display face — the app's only
              // other appearance of the iris-ring motif, kept quiet here.
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: [
                        ClarusColors.ink,
                        ClarusColors.accent,
                        ClarusColors.ink
                      ]),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Clarus',
                      style: Theme.of(context).textTheme.displaySmall),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'AI-assisted diabetic retinopathy referral screening',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Text('Your name', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Nurse Reyes',
                  filled: true,
                  fillColor: ClarusColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ClarusColors.divider),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Your role', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'Health Worker', label: Text('Health Worker')),
                  ButtonSegment(value: 'Physician', label: Text('Physician')),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _continue, child: const Text('Continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
