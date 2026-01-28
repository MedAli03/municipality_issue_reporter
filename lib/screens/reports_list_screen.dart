import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../localization/app_localizations.dart';
import '../models/report.dart';
import '../storage/hive_boxes.dart';
import 'report_details_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final box = Hive.box<Report>(reportsBoxName);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myReports),
      ),
      body: ValueListenableBuilder<Box<Report>>(
        valueListenable: box.listenable(),
        builder: (context, reportsBox, _) {
          final reports = reportsBox.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.noReports,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.noReportsHint,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final report = reports[index];
              final hasPhoto = report.photoPath != null;
              final hasLocation =
                  report.latitude != null && report.longitude != null;
              return ListTile(
                title: Text(report.title),
                subtitle: Text(
                  '${localizations.createdAt}: ${_formatDate(report.createdAt)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hasPhoto
                          ? localizations.photoStatusPresent
                          : localizations.photoStatusMissing,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasLocation
                          ? localizations.locationStatusPresent
                          : localizations.locationStatusMissing,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(report: report),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
