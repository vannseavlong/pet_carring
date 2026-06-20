import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.serviceId,
    required super.name,
    required super.description,
    required super.priceFrom,
    required super.icon,
    required super.color,
    required super.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      priceFrom: (json['price_from'] as num).toDouble(),
      icon: json['icon'] as String,
      color: json['color'] as String,
      category: json['category'] as String,
    );
  }
}
