import 'package:flutter/material.dart';

import '../models/follow_up_plan.dart';
import '../models/history_entry.dart';
import 'past_result_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  late Future<List<FollowUpPlan>> _plans;
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _plans = _apiService.fetchFollowUpPlans();
  }

  Future<void> _refresh() async {
    setState(() {
      _plans = _apiService.fetchFollowUpPlans();
    });
    await _plans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring list')),
      body: FutureBuilder<List<FollowUpPlan>>(
        future: _plans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load monitoring plans. Pull to retry.'),
            );
          }
          final plans = snapshot.data ?? [];
          final query = _searchController.text.trim().toLowerCase();
          final filteredPlans = plans.where((plan) {
            final matchesSearch =
                query.isEmpty || plan.patientId.toLowerCase().contains(query);
            final matchesStatus = _statusFilter == 'All' ||
                plan.status == _statusFilter.toLowerCase();
            return matchesSearch && matchesStatus;
          }).toList();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Search patient',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final filter in const [
                        'All',
                        'Scheduled',
                        'Overdue',
                        'Completed',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _statusFilter == filter,
                            onSelected: (_) =>
                                setState(() => _statusFilter = filter),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredPlans.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 180),
                            Center(child: Text('No matching monitoring plans')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: filteredPlans.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => _PlanTile(
                            plan: filteredPlans[index],
                            onChanged: _refresh,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final FollowUpPlan plan;
  final Future<void> Function() onChanged;

  const _PlanTile({required this.plan, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isOverdue = plan.status == 'overdue';
    final statusColor = isOverdue ? ClarusColors.refer : ClarusColors.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClarusColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ClarusColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.patientId,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Tooltip(
                message: 'View past screening result',
                child: TextButton.icon(
                  onPressed: () => _showPastResult(context),
                  style: TextButton.styleFrom(
                    foregroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(
                    plan.status,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: ClarusColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text('Return ${_formatDate(plan.returnDate)}'),
              const Spacer(),
              const Icon(Icons.email_outlined),
              const SizedBox(width: 4),
              Text(plan.contactMethod),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.status == 'overdue'
                ? 'Needs follow-up action - ${plan.reminderCount} '
                    'reminder${plan.reminderCount == 1 ? '' : 's'} sent'
                : 'Reminder scheduled',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 2),
                      initialDate: plan.returnDate.isBefore(DateTime.now())
                          ? DateTime.now()
                          : plan.returnDate,
                    );
                    if (date != null) {
                      try {
                        await ApiService().updateFollowUpPlan(plan.followUpId, {
                          'return_date':
                              date.toIso8601String().split('T').first,
                        });
                        await onChanged();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Rescheduled to ${_formatDate(date)}',
                              ),
                            ),
                          );
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Rescheduling failed: $error'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Reschedule'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await ApiService().updateFollowUpPlan(plan.followUpId, {
                      'status': 'completed',
                    });
                    await onChanged();
                  },
                  child: const Text('Mark complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _showPastResult(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading result...'),
          ],
        ),
      ),
    );

    HistoryEntry? result;
    String? error;

    if (plan.encounterId == null) {
      error = 'No screening result is linked to this follow-up plan.';
    } else {
      try {
        final history = await ApiService().fetchHistory();
        for (final entry in history) {
          if (entry.encounterId == plan.encounterId) {
            result = entry;
            break;
          }
        }
        error ??= result == null
            ? 'The linked screening result could not be found.'
            : null;
      } catch (_) {
        error = 'Could not load the past screening result.';
      }
    }

    if (!context.mounted) return;
    Navigator.pop(context);
    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error!)));
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PastResultScreen(result: result!, patientId: plan.patientId),
      ),
    );
  }
}
