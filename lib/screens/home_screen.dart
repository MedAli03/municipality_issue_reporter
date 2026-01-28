import 'package:flutter/material.dart';

import '../models/report_draft.dart';
import 'create_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReportDraft? _latestDraft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Municipality Issue Reporter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App running (Firebase postponed)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'You can still capture a draft report locally.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              _latestDraft == null
                  ? 'No draft saved yet.'
                  : 'Draft: ${_latestDraft!.title}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_latestDraft != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_latestDraft!.governorate} · ${_latestDraft!.city}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                _latestDraft!.latitude != null && _latestDraft!.longitude != null
                    ? 'Coordinates: '
                        '${_latestDraft!.latitude!.toStringAsFixed(6)}, '
                        '${_latestDraft!.longitude!.toStringAsFixed(6)}'
                    : 'No coordinates',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<ReportDraft>(
                  MaterialPageRoute(
                    builder: (context) => const CreateReportScreen(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _latestDraft = result;
                  });
                }
              },
              child: const Text('New report'),
            ),
          ],
        ),
      ),
    );
  }
}
