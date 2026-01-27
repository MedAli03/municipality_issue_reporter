import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key, required this.firebaseInitialization});

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

        return const HomeScreen();
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
