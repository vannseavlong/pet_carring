import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String shopId;
  final String name;
  final String description;
  final String logo;
  final String banner;
  final String contactEmail;
  final String contactPhone;
  final String hours;
  final String status;
  final String categoryId;

  const Shop({
    required this.shopId,
    required this.name,
    required this.description,
    required this.logo,
    this.banner = '',
    required this.contactEmail,
    required this.contactPhone,
    required this.hours,
    required this.status,
    this.categoryId = '',
  });

  @override
  List<Object?> get props => [
    shopId,
    name,
    description,
    logo,
    banner,
    contactEmail,
    contactPhone,
    hours,
    status,
    categoryId,
  ];
}
