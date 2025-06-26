class UserPreferenceModel {
  final int numberOfPeople;
  final bool hasSmallChildren;
  final bool hasSeniorTravelers;
  final String carLength;
  final bool hasDogs;

  UserPreferenceModel({
    required this.numberOfPeople,
    required this.hasSmallChildren,
    required this.hasSeniorTravelers,
    required this.carLength,
    required this.hasDogs,
  });

  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      numberOfPeople: json['numberOfPeople'],
      hasSmallChildren: json['hasSmallChildren'],
      hasSeniorTravelers: json['hasSeniorTravelers'],
      carLength: json['carLength'],
      hasDogs: json['hasDogs'],
    );
  }
}
