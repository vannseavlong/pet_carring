import '../../core/errors/app_exception.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/category_local_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remote;
  final CategoryLocalDataSource _local;

  CategoryRepositoryImpl(this._remote, this._local);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final categories = await _remote.getCategories();
      await _local.cacheCategories(categories);
      return categories;
    } on AppException {
      return _local.getCachedCategories();
    }
  }
}
