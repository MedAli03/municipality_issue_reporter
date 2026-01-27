import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(firebaseInitialization: Firebase.initializeApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.firebaseInitialization});

  final Future<FirebaseApp> firebaseInitialization;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Municipality Issue Reporter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirebaseInitializationScreen(
        firebaseInitialization: firebaseInitialization,
      ),
    );
  }
}

class FirebaseInitializationScreen extends StatelessWidget {
  const FirebaseInitializationScreen({
    super.key,
    required this.firebaseInitialization,
  });

  final Future<FirebaseApp> firebaseInitialization;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StatusScaffold(
            title: 'Firebase initialization failed',
            lines: [
              'Error: ${snapshot.error}',
            ],
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const StatusScaffold(
            title: 'Initializing Firebase',
            lines: ['Please wait...'],
            showProgress: true,
          );
        }

        return const FirebaseSmokeTestScreen();
      },
    );
  }
}

class FirebaseSmokeTestScreen extends StatefulWidget {
  const FirebaseSmokeTestScreen({super.key});

  @override
  State<FirebaseSmokeTestScreen> createState() => _FirebaseSmokeTestScreenState();
}

class _FirebaseSmokeTestScreenState extends State<FirebaseSmokeTestScreen> {
  late final Future<SmokeTestResult> _smokeTestFuture;

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
              'Firestore error: ${snapshot.error}',
              'Storage error: ${snapshot.error}',
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

        return StatusScaffold(
          title: 'Firebase initialized',
          lines: [
            result.firestoreMessage,
            result.storageMessage,
          ],
        );
      },
    );
  }
}

class StatusScaffold extends StatelessWidget {
  const StatusScaffold({
    super.key,
    required this.title,
    required this.lines,
    this.showProgress = false,
  });

  final String title;
  final List<String> lines;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(),
                ),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
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
