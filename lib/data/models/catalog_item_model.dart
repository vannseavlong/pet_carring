import '../../domain/entities/catalog_item.dart';

class CatalogItemModel extends CatalogItem {
  const CatalogItemModel({
    required super.itemId,
    required super.shopId,
    required super.itemType,
    required super.name,
    required super.description,
    required super.priceFrom,
    required super.icon,
    required super.color,
    required super.category,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> json) {
    return CatalogItemModel(
      itemId: json['item_id'] as String,
      shopId: json['shop_id'] as String,
      itemType: json['item_type'] as String? ?? CatalogItemType.service,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      priceFrom: (json['price_from'] as num).toDouble(),
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '#E8F0EE',
      category: json['category'] as String? ?? '',
    );
  }
}
