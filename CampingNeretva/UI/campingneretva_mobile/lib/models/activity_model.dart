class Activity {
  final int id;
  final String name;
  final String description;
  final DateTime date;
  final double price;
  final String imageUrl;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.price,
    required this.imageUrl,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activityId'],
      name: json['name'],
      description: json['description'],
      date:
          json['date'] is String
              ? DateTime.parse(json['date'])
              : DateTime.now(),
      price: json['price'],
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_activity.png',
    );
  }
}
