import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String shopId;
  final String name;
  final String description;
  final String logo;
  final String contactEmail;
  final String contactPhone;
  final String hours;
  final String status;
  final String category;

  const Shop({
    required this.shopId,
    required this.name,
    required this.description,
    required this.logo,
    required this.contactEmail,
    required this.contactPhone,
    required this.hours,
    required this.status,
    this.category = '',
  });

  @override
  List<Object?> get props => [
    shopId,
    name,
    description,
    logo,
    contactEmail,
    contactPhone,
    hours,
    status,
    category,
  ];
}
