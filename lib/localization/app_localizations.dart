import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late final Map<String, String> _localizedStrings;

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<void> load() async {
    final jsonString = await rootBundle
        .loadString('lib/l10n/app_${locale.languageCode}.arb');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  String _lookup(String key) => _localizedStrings[key] ?? key;

  String get appTitle => _lookup('app_title');
  String get newReport => _lookup('new_report');
  String get myReports => _lookup('my_reports');
  String get titleLabel => _lookup('title_label');
  String get descriptionLabel => _lookup('description_label');
  String get pickFromGallery => _lookup('pick_from_gallery');
  String get openCamera => _lookup('open_camera');
  String get removeImage => _lookup('remove_image');
  String get getLocation => _lookup('get_location');
  String get saveReport => _lookup('save_report');
  String get confirmSubmit => _lookup('confirm_submit');
  String get confirmSubmitMessage => _lookup('confirm_submit_message');
  String get cancel => _lookup('cancel');
  String get confirm => _lookup('confirm');
  String get noReports => _lookup('no_reports');
  String get noReportsHint => _lookup('no_reports_hint');
  String get reportSaved => _lookup('report_saved');
  String get saveFailed => _lookup('save_failed');
  String get permissionDenied => _lookup('permission_denied');
  String get locationServicesDisabled => _lookup('location_services_disabled');
  String get detailsTitle => _lookup('details_title');
  String get createdAt => _lookup('created_at');
  String get photoLabel => _lookup('photo_label');
  String get photoMissing => _lookup('photo_missing');
  String get locationLabel => _lookup('location_label');
  String get noLocation => _lookup('no_location');
  String get photoStatusPresent => _lookup('photo_status_present');
  String get photoStatusMissing => _lookup('photo_status_missing');
  String get locationStatusPresent => _lookup('location_status_present');
  String get locationStatusMissing => _lookup('location_status_missing');

  String locationCaptured({required String lat, required String lng}) {
    return _lookup('location_captured')
        .replaceAll('{lat}', lat)
        .replaceAll('{lng}', lng);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
