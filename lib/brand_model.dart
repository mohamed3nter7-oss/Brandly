import 'dart:ui';

class BrandModel {
  final String id;
  final String name;
  final String subtitle;
  final String image;
  final Color color;

  BrandModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.image,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'image': image,
        'color': color.value,
      };

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
        id: json['id'],
        name: json['name'],
        subtitle: json['subtitle'],
        image: json['image'],
        color: Color(json['color']),
      );
}
