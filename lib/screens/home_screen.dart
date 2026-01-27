import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../models/report_draft.dart';
import 'create_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<SmokeTestResult> _smokeTestFuture;
  ReportDraft? _latestDraft;

  @override
  void initState() {
    super.initState();
    _smokeTestFuture = _runSmokeTests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SmokeTestResult>(
      future: _smokeTestFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StatusScaffold(
            title: 'Firebase initialized',
            lines: [
              'Smoke test error: ${snapshot.error}',
            ],
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const StatusScaffold(
            title: 'Firebase initialized',
            lines: ['Running smoke tests...'],
            showProgress: true,
          );
        }

        final result = snapshot.data;
        if (result == null) {
          return const StatusScaffold(
            title: 'Firebase initialized',
            lines: ['Smoke tests returned no data.'],
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Project initialized'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.firestoreMessage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  result.storageMessage,
                  style: Theme.of(context).textTheme.titleMedium,
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
                    _latestDraft!.latitude != null &&
                            _latestDraft!.longitude != null
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
      },
    );
  }
}

class SmokeTestResult {
  SmokeTestResult({
    required this.firestoreMessage,
    required this.storageMessage,
  });

  final String firestoreMessage;
  final String storageMessage;
}

Future<SmokeTestResult> _runSmokeTests() async {
  final firestoreMessage = await _runFirestoreSmokeTest();
  final storageMessage = await _runStorageSmokeTest();
  return SmokeTestResult(
    firestoreMessage: firestoreMessage,
    storageMessage: storageMessage,
  );
}

Future<String> _runFirestoreSmokeTest() async {
  try {
    final collection = FirebaseFirestore.instance.collection('healthchecks');
    final docRef = collection.doc();
    await docRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'platform': _platformLabel(),
    });
    await docRef.get();
    return 'Firestore OK';
  } catch (error) {
    return 'Firestore error: $error';
  }
}

Future<String> _runStorageSmokeTest() async {
  final ref = FirebaseStorage.instance.ref('healthchecks/ping.txt');
  try {
    await ref.getDownloadURL();
    return 'Storage OK';
  } on FirebaseException catch (error) {
    if (error.code == 'object-not-found') {
      return 'Storage configured';
    }
    return 'Storage error: ${error.message ?? error.code}';
  } catch (error) {
    return 'Storage error: $error';
  }
}

String _platformLabel() {
  if (kIsWeb) {
    return 'web';
  }
  if (Platform.isAndroid) {
    return 'android';
  }
  if (Platform.isIOS) {
    return 'ios';
  }
  return 'unknown';
}
