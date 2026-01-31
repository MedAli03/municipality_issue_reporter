import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/admin_auth_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _authService = AdminAuthService();
  bool _saving = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          localizations.changePin,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPinController,
                decoration: InputDecoration(
                  labelText: localizations.currentPin,
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) => _validateRequired(value, localizations),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPinController,
                decoration: InputDecoration(
                  labelText: localizations.newPin,
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateNewPin(value, localizations),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPinController,
                decoration: InputDecoration(
                  labelText: localizations.confirmNewPin,
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    _validateConfirmPin(value, localizations),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _savePin,
                child: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(localizations.save),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _logout,
          child: Text(localizations.logout),
        ),
      ],
    );
  }

  String? _validateRequired(String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.requiredField;
    }
    return null;
  }

  String? _validateNewPin(String? value, AppLocalizations localizations) {
    final requiredMessage = _validateRequired(value, localizations);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if ((value ?? '').trim().length < 4) {
      return localizations.pinMinLength;
    }
    return null;
  }

  String? _validateConfirmPin(String? value, AppLocalizations localizations) {
    final requiredMessage = _validateRequired(value, localizations);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (value?.trim() != _newPinController.text.trim()) {
      return localizations.pinMismatch;
    }
    return null;
  }

  Future<void> _savePin() async {
    final localizations = AppLocalizations.of(context);
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final currentPin = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();

    try {
      final isCorrect = await _authService.verifyPin(currentPin);
      if (!isCorrect) {
        _showSnackBar(localizations.wrongPin);
        return;
      }
      await _authService.setPin(newPin);
      _currentPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
      _showSnackBar(localizations.pinChanged);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    widget.onLogout();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
