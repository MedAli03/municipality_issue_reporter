import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/report.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../storage/hive_boxes.dart';
import '../utils/validators.dart';
import 'reports_list_screen.dart';

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
  final _landmarkController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _locationService = LocationService();
  final _photoService = PhotoService();
  final _uuid = const Uuid();

  String? _photoPath;
  bool _saving = false;
  bool _loadingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
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
              controller: _landmarkController,
              decoration: const InputDecoration(labelText: 'Landmark (optional)'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude (optional)'),
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
              decoration: const InputDecoration(labelText: 'Longitude (optional)'),
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
            ElevatedButton.icon(
              onPressed: _loadingLocation ? null : _useGps,
              icon: _loadingLocation
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Use my GPS'),
            ),
            const SizedBox(height: 16),
            Text(
              'Photo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photoPath!),
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text(
                    'Photo unavailable (file missing).',
                  ),
                ),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Center(child: Text('No photo selected')),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: Text(_photoPath == null ? 'Add photo' : 'Change photo'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _saveReport,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useGps() async {
    setState(() {
      _loadingLocation = true;
    });
    try {
      final position = await _locationService.getCurrentPositionWithPermission();
      if (position != null) {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      }
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<_PhotoSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(_PhotoSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(_PhotoSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    String? path;
    if (source == _PhotoSource.camera) {
      path = await _photoService.pickFromCamera();
    } else {
      path = await _photoService.pickFromGallery();
    }

    if (path != null && mounted) {
      setState(() {
        _photoPath = path;
      });
    }
  }

  Future<void> _saveReport() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final latitude = _latitudeController.text.trim().isEmpty
          ? null
          : double.tryParse(_latitudeController.text.trim());
      final longitude = _longitudeController.text.trim().isEmpty
          ? null
          : double.tryParse(_longitudeController.text.trim());

      final report = Report(
        id: _uuid.v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        governorate: _governorateController.text.trim(),
        city: _cityController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        photoPath: _photoPath,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final box = Hive.box<Report>(reportsBoxName);
      await box.put(report.id, report);

      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ReportsListScreen(),
        ),
      );
    } catch (error) {
      _showSnackBar('Unable to save report: $error');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _PhotoSource { camera, gallery }
