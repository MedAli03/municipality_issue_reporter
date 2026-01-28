import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/report.dart';
import '../storage/hive_boxes.dart';
import 'report_details_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Report>(reportsBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
      ),
      body: ValueListenableBuilder<Box<Report>>(
        valueListenable: box.listenable(),
        builder: (context, reportsBox, _) {
          final reports = reportsBox.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (reports.isEmpty) {
            return const Center(
              child: Text('No reports yet.'),
            );
          }

          return ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text(report.title),
                subtitle: Text('${report.governorate} · ${report.city}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(report.status),
                    const SizedBox(height: 4),
                    Text(_formatDate(report.createdAt)),
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
