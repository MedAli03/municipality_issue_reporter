class ReportDraft {
  const ReportDraft({
    required this.title,
    required this.description,
    required this.governorate,
    required this.city,
    this.street,
    this.latitude,
    this.longitude,
  });

  final String title;
  final String description;
  final String governorate;
  final String city;
  final String? street;
  final double? latitude;
  final double? longitude;

  ReportDraft copyWith({
    String? title,
    String? description,
    String? governorate,
    String? city,
    String? street,
    double? latitude,
    double? longitude,
  }) {
    return ReportDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      street: street ?? this.street,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'governorate': governorate,
      'city': city,
      'street': street,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
