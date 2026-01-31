import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../localization/app_localizations.dart';
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
  final _locationService = LocationService();
  final _photoService = PhotoService();
  final _uuid = const Uuid();

  String? _photoPath;
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  bool _loadingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.newReport),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: localizations.titleLabel),
              textInputAction: TextInputAction.next,
              validator: (value) => validateRequired(
                value,
                fieldName: localizations.titleLabel,
                minLength: 5,
              ),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  InputDecoration(labelText: localizations.descriptionLabel),
              maxLines: 4,
              validator: (value) => validateRequired(
                value,
                fieldName: localizations.descriptionLabel,
                minLength: 10,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.photoLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_photoPath != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_photoPath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SizedBox(
                        height: 180,
                        child: Center(
                          child: Text(localizations.photoMissing),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: localizations.removeImage,
                    onPressed: () {
                      setState(() {
                        _photoPath = null;
                      });
                    },
                  ),
                ],
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Center(child: Text(localizations.photoStatusMissing)),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: Text(localizations.pickFromGallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(localizations.openCamera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              localizations.locationLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _latitude != null && _longitude != null
                  ? localizations.locationCaptured(
                      lat: _latitude!.toStringAsFixed(6),
                      lng: _longitude!.toStringAsFixed(6),
                    )
                  : localizations.noLocation,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadingLocation ? null : _getLocation,
              icon: _loadingLocation
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(localizations.getLocation),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _confirmSaveReport,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(localizations.saveReport),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final path = await _photoService.pickFromGallery();
    if (path != null && mounted) {
      setState(() {
        _photoPath = path;
      });
    }
  }

  Future<void> _openCamera() async {
    final path = await _photoService.pickFromCamera();
    if (path != null && mounted) {
      setState(() {
        _photoPath = path;
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _loadingLocation = true;
    });
    try {
      final position = await _locationService.getCurrentPositionWithPermission();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final localizations = AppLocalizations.of(context);
      final message = error.toString().contains('permission')
          ? localizations.permissionDenied
          : error.toString().contains('services')
              ? localizations.locationServicesDisabled
              : error.toString();
      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _confirmSaveReport() async {
    final localizations = AppLocalizations.of(context);
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmSubmit),
        content: Text(localizations.confirmSubmitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );

    if (shouldSave != true) {
      return;
    }

    await _saveReport();
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
      final report = Report(
        id: _uuid.v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoPath: _photoPath,
        latitude: _latitude,
        longitude: _longitude,
        createdAt: DateTime.now(),
      );

      final box = Hive.box<Report>(reportsBoxName);
      await box.put(report.id, report);

      if (!mounted) {
        return;
      }

      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.reportSaved)),
      );

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ReportsListScreen(),
        ),
      );
    } catch (error) {
      final localizations = AppLocalizations.of(context);
      _showSnackBar('${localizations.saveFailed} $error');
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
