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
  String _contactMethod = 'SMS';
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
        contactMethod: _contactMethod,
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
          'The patient will be reminded 7 days before, 1 day before, and on '
          'the return date. The plan still needs to be connected to the '
          'notification service before messages are sent.',
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
            style: Theme.of(context).textTheme.headlineSmall
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
            keyboardType: _contactMethod == 'SMS'
                ? TextInputType.phone
                : TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _contactMethod == 'SMS'
                  ? 'Mobile number'
                  : 'Email address',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Reminder channel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'SMS',
                label: Text('SMS'),
                icon: Icon(Icons.sms_outlined),
              ),
              ButtonSegment(
                value: 'Email',
                label: Text('Email'),
                icon: Icon(Icons.email_outlined),
              ),
            ],
            selected: {_contactMethod},
            onSelectionChanged: (selection) {
              setState(() => _contactMethod = selection.first);
            },
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
                const Text('7 days before the return date'),
                const Text('1 day before the return date'),
                const Text('On the return date'),
                const Text('Follow-up task after a missed visit'),
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
