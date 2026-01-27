import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/report_draft.dart';
import '../utils/validators.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report (draft)'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              validator: (value) => validateRequired(
                value,
                fieldName: 'Title',
                minLength: 5,
              ),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
              validator: (value) => validateRequired(
                value,
                fieldName: 'Description',
                minLength: 10,
              ),
            ),
            TextFormField(
              controller: _governorateController,
              decoration: const InputDecoration(labelText: 'Governorate'),
              textInputAction: TextInputAction.next,
              validator: (value) => validateRequired(
                value,
                fieldName: 'Governorate',
                minLength: 2,
              ),
            ),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City/Delegation'),
              textInputAction: TextInputAction.next,
              validator: (value) => validateRequired(
                value,
                fieldName: 'City/Delegation',
                minLength: 2,
              ),
            ),
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Street / Landmark'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (value) {
                final pairError = validateLatLngPair(
                  lat: value,
                  lng: _longitudeController.text,
                );
                if (pairError != null) {
                  return pairError;
                }
                return validateLatitude(value);
              },
            ),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (value) {
                final pairError = validateLatLngPair(
                  lat: _latitudeController.text,
                  lng: value,
                );
                if (pairError != null) {
                  return pairError;
                }
                return validateLongitude(value);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _useGps,
              child: const Text('Use my GPS'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveDraft,
              child: const Text('Save draft'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useGps() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled.');
      return;
    }

    var permission = await Permission.locationWhenInUse.status;
    if (!permission.isGranted) {
      permission = await Permission.locationWhenInUse.request();
    }

    if (permission.isPermanentlyDenied) {
      _showSnackBar('Enable location permission in settings.');
      return;
    }

    if (!permission.isGranted) {
      _showSnackBar('Location permission denied.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
      _showSnackBar('GPS location filled');
    } catch (error) {
      _showSnackBar('Unable to fetch current location.');
    }
  }

  void _saveDraft() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final latitude = _latitudeController.text.trim().isEmpty
        ? null
        : double.tryParse(_latitudeController.text.trim());
    final longitude = _longitudeController.text.trim().isEmpty
        ? null
        : double.tryParse(_longitudeController.text.trim());

    final draft = ReportDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      governorate: _governorateController.text.trim(),
      city: _cityController.text.trim(),
      street: _streetController.text.trim().isEmpty
          ? null
          : _streetController.text.trim(),
      latitude: latitude,
      longitude: longitude,
    );

    Navigator.of(context).pop(draft);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
