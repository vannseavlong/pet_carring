import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.categoryId,
    required super.name,
    required super.icon,
    required super.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
