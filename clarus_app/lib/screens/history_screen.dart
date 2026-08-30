import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/history_entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<HistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiService.fetchHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _apiService.fetchHistory();
    });
  }

  String _formatTimestamp(String isoTimestamp) {
    try {
      final dt = DateTime.parse(isoTimestamp).toLocal();
      return '${dt.month}/${dt.day}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoTimestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening History'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<HistoryEntry>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                // ListView (not Center) so pull-to-refresh still works
                // even when the initial load failed.
                children: [
                  const SizedBox(height: 100),
                  const Icon(Icons.cloud_off,
                      size: 40, color: ClarusColors.textMuted),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Could not load history.\nPull down to try again.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              );
            }

            final entries = snapshot.data ?? [];

            if (entries.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      'No screenings yet — start one from the Home tab.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final triageText = entry.triage ?? 'Unknown';
                final color = ClarusColors.forTriage(triageText);

                return Container(
                  decoration: BoxDecoration(
                    color: ClarusColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ClarusColors.divider),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                            width: 5,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(14)),
                            )),
                        Expanded(
                          child: ListTile(
                            title: Text('Encounter ${entry.encounterId}',
                                style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(
                              '${entry.workerName} · ${_formatTimestamp(entry.timestamp)}',
                              style: ClarusType.mono(size: 12),
                            ),
                            trailing: Text(triageText,
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
