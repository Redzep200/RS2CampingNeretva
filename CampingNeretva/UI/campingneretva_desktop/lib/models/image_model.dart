class ImageModel {
  final int imageId;
  final String path;
  final String contentType;
  final DateTime dateCreated;

  ImageModel({
    required this.imageId,
    required this.path,
    required this.contentType,
    required this.dateCreated,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imageId: json['imageId'],
      path: json['path'],
      contentType: json['contentType'],
      dateCreated: DateTime.parse(json['dateCreated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'path': path,
      'contentType': contentType,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }
}
