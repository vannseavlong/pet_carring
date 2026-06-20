import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String serviceId;
  final String name;
  final String description;
  final double priceFrom;
  final String icon;
  final String color;
  final String category;

  const Service({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.priceFrom,
    required this.icon,
    required this.color,
    required this.category,
  });

  @override
  List<Object?> get props =>
      [serviceId, name, description, priceFrom, icon, color, category];
}
