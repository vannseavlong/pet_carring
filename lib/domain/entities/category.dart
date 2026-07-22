import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String categoryId;
  final String name;
  final String icon;
  final int sortOrder;

  const Category({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [categoryId, name, icon, sortOrder];
}
