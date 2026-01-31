import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/admin_auth_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinController = TextEditingController();
  final _authService = AdminAuthService();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.adminLogin),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: localizations.pin,
                hintText: localizations.enterPin,
              ),
              onSubmitted: (_) => _attemptLogin(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _attemptLogin,
              child: Text(localizations.login),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _attemptLogin() async {
    final pin = _pinController.text.trim();
    final localizations = AppLocalizations.of(context);
    final isValid = await _authService.verifyPin(pin);
    if (!isValid) {
      _showSnackBar(localizations.wrongPin);
      return;
    }
    await _authService.setLoggedIn(true);
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AdminDashboardScreen(),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
