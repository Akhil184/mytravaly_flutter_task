class Hotel {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final double rating;
  final String thumbnailUrl;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.rating,
    required this.thumbnailUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['hotel_name'] ?? 'Unknown',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 0.0,
      thumbnailUrl: json['thumbnail'] ?? json['image'] ?? '',
    );
  }
}
