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

  // UI constants (matching screenshot vibe)
  static const _accentPurple = Color(0xFF5B4BB7);
  static const _saveBlue = Color(0xFF0B2D5C);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _underlineFieldDecoration({
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black38,
        fontWeight: FontWeight.w500,
      ),
      border: const UnderlineInputBorder(),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black54, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }

  ButtonStyle _outlinedPrimaryStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: _accentPurple,
      side: const BorderSide(color: _accentPurple, width: 1.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      minimumSize: const Size.fromHeight(52),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: Text(
          localizations.newReport,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Banner(
        message: 'BETA',
        location: BannerLocation.topEnd,
        color: Colors.black26,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              children: [
                // Title (underline style, hint only)
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 20),
                  decoration: _underlineFieldDecoration(
                    hint: localizations.titleLabel,
                  ),
                  validator: (value) => validateRequired(
                    value,
                    fieldName: localizations.titleLabel,
                    minLength: 5,
                  ),
                ),

                const SizedBox(height: 16),

                // Description (underline style, hint only)
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  decoration: _underlineFieldDecoration(
                    hint: localizations.descriptionLabel,
                  ),
                  validator: (value) => validateRequired(
                    value,
                    fieldName: localizations.descriptionLabel,
                    minLength: 10,
                  ),
                ),

                const SizedBox(height: 22),

                // Photo section title
                Text(
                  localizations.photoLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                // Photo preview / placeholder
                if (_photoPath != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          File(_photoPath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.grey.shade200,
                            ),
                            child: Text(
                              localizations.photoMissing,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Material(
                          color: Colors.white70,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: localizations.removeImage,
                            onPressed: () => setState(() => _photoPath = null),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 150,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade200,
                          Colors.grey.shade300,
                        ],
                      ),
                    ),
                    child: Text(
                      localizations.photoStatusMissing, // "No photo"
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                // Photo buttons (stacked full width)
                OutlinedButton.icon(
                  style: _outlinedPrimaryStyle(),
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(localizations.pickFromGallery),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: _outlinedPrimaryStyle(),
                  onPressed: _openCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(localizations.openCamera),
                ),

                const SizedBox(height: 24),

                // Location section
                Text(
                  localizations.locationLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _latitude != null && _longitude != null
                      ? localizations.locationCaptured(
                          lat: _latitude!.toStringAsFixed(6),
                          lng: _longitude!.toStringAsFixed(6),
                        )
                      : localizations.noLocation, // "No location captured."
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  style: _outlinedPrimaryStyle(),
                  onPressed: _loadingLocation ? null : _getLocation,
                  icon: _loadingLocation
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_on_outlined),
                  label: Text(localizations.getLocation),
                ),

                const SizedBox(height: 18),

                // Save button (big, dark blue)
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _saveBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      elevation: 0,
                    ),
                    onPressed: _saving ? null : _confirmSaveReport,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(localizations.saveReport),
                  ),
                ),
              ],
            ),
          ),
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
      final position =
          await _locationService.getCurrentPositionWithPermission();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (error) {
      if (!mounted) return;

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

    if (shouldSave != true) return;
    await _saveReport();
  }

  Future<void> _saveReport() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _saving = true);

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

      if (!mounted) return;

      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.reportSaved)),
      );

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ReportsListScreen()),
      );
    } catch (error) {
      final localizations = AppLocalizations.of(context);
      _showSnackBar('${localizations.saveFailed} $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
