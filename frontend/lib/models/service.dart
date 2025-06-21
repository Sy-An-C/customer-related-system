class Service {
  final int id;
  final String name;
  final String category;
  final int duration;
  final double price;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'general',
      duration: json['duration'],
      price: json['price']?.toDouble() ?? 0.0,
    );
  }
}