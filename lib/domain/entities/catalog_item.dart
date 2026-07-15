import 'package:equatable/equatable.dart';

abstract final class CatalogItemType {
  static const service = 'service';
  static const product = 'product';
}

class CatalogItem extends Equatable {
  final String itemId;
  final String shopId;
  final String itemType;
  final String name;
  final String description;
  final double priceFrom;
  final String icon;
  final String color;
  final String category;

  const CatalogItem({
    required this.itemId,
    required this.shopId,
    required this.itemType,
    required this.name,
    required this.description,
    required this.priceFrom,
    required this.icon,
    required this.color,
    required this.category,
  });

  @override
  List<Object?> get props => [
    itemId,
    shopId,
    itemType,
    name,
    description,
    priceFrom,
    icon,
    color,
    category,
  ];
}
