import 'package:flutter/material.dart';

import '../models/screening_result.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class FollowUpScreen extends StatefulWidget {
  final ScreeningResult result;

  const FollowUpScreen({super.key, required this.result});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final _patientIdController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime? _returnDate;
  bool _consentGiven = false;
  bool _saving = false;

  @override
  void dispose() {
    _patientIdController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _chooseReturnDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      initialDate: _returnDate ?? today.add(const Duration(days: 30)),
    );

    if (selected != null) {
      setState(() => _returnDate = selected);
    }
  }

  Future<void> _savePlan() async {
    if (_patientIdController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty ||
        _returnDate == null ||
        !_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete the patient details, return date, and consent.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService().createFollowUpPlan(
        patientId: _patientIdController.text.trim(),
        encounterId: widget.result.encounterId,
        contactMethod: 'Email',
        contactValue: _contactController.text.trim(),
        consentGiven: _consentGiven,
        returnDate: _returnDate!,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save follow-up plan: $error')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Follow-up plan ready'),
        content: const Text(
          'An email will be sent 7 days before the return date and again on '
          'the return date. The plan will then be flagged as overdue on the '
          'Monitoring list if the visit is missed.',
        ),
        actions: [
          FilledButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Choose return date';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create follow-up plan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Monitor result',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: ClarusColors.accent),
          ),
          const SizedBox(height: 6),
          Text(
            'Record the clinician-recommended return date. This result does not set a medical appointment interval by itself.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _patientIdController,
            decoration: const InputDecoration(
              labelText: 'Patient name or ID',
              hintText: 'Use the clinic identifier if preferred',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recommended return date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _chooseReturnDate,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(_formatDate(_returnDate)),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _consentGiven,
            onChanged: (value) =>
                setState(() => _consentGiven = value ?? false),
            title: const Text('Patient consented to reminders'),
            subtitle: const Text(
              'The patient can withdraw consent through the health center.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ClarusColors.canvas,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClarusColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder schedule',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Email sent 7 days before the return date'),
                const Text('A second email on the return date'),
                const Text(
                  'Flagged as overdue on the Monitoring list after that',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _savePlan,
              icon: const Icon(Icons.event_available_outlined),
              label: Text(_saving ? 'Saving...' : 'Save follow-up plan'),
            ),
          ),
        ],
      ),
    );
  }
}
