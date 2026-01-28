import 'dart:io';

import 'package:flutter/material.dart';

import '../models/report.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoRow(label: 'Title', value: report.title),
          _InfoRow(label: 'Description', value: report.description),
          _InfoRow(
            label: 'Created',
            value: report.createdAt.toLocal().toString(),
          ),
          _InfoRow(
            label: 'Coordinates',
            value: report.latitude != null && report.longitude != null
                ? '${report.latitude!.toStringAsFixed(6)}, '
                    '${report.longitude!.toStringAsFixed(6)}'
                : '—',
          ),
          const SizedBox(height: 16),
          Text(
            'Photo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (report.photoPath != null &&
              File(report.photoPath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(report.photoPath!),
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Center(
                child: Text('No photo available'),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
