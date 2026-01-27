String? validateRequired(
  String? value, {
  required String fieldName,
  int minLength = 1,
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return '$fieldName is required.';
  }
  if (trimmed.length < minLength) {
    return '$fieldName must be at least $minLength characters.';
  }
  return null;
}

String? validateLatitude(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  final parsed = double.tryParse(trimmed);
  if (parsed == null) {
    return 'Latitude must be a number.';
  }
  if (parsed < -90 || parsed > 90) {
    return 'Latitude must be between -90 and 90.';
  }
  return null;
}

String? validateLongitude(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  final parsed = double.tryParse(trimmed);
  if (parsed == null) {
    return 'Longitude must be a number.';
  }
  if (parsed < -180 || parsed > 180) {
    return 'Longitude must be between -180 and 180.';
  }
  return null;
}

String? validateLatLngPair({required String? lat, required String? lng}) {
  final latTrimmed = lat?.trim() ?? '';
  final lngTrimmed = lng?.trim() ?? '';
  if (latTrimmed.isEmpty && lngTrimmed.isEmpty) {
    return null;
  }
  if (latTrimmed.isEmpty || lngTrimmed.isEmpty) {
    return 'Enter both latitude and longitude, or leave both empty.';
  }
  return null;
}
