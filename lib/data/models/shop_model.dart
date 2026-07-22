import '../../domain/entities/shop.dart';

class ShopModel extends Shop {
  const ShopModel({
    required super.shopId,
    required super.name,
    required super.description,
    required super.logo,
    super.banner,
    required super.contactEmail,
    required super.contactPhone,
    required super.hours,
    required super.status,
    super.categoryId,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      banner: json['banner'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      categoryId: json['category_id'] as String? ?? '',
    );
  }
}
