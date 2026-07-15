import '../../domain/entities/shop.dart';

class ShopModel extends Shop {
  const ShopModel({
    required super.shopId,
    required super.name,
    required super.description,
    required super.logo,
    required super.contactEmail,
    required super.contactPhone,
    required super.hours,
    required super.status,
    super.category,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      // Not on the backend `shops` schema yet — falls back to the shop's
      // primary catalog category if/when the API starts sending one.
      category: json['category'] as String? ?? '',
    );
  }
}
