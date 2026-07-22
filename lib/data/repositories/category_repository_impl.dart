import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/remote/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remote;

  CategoryRepositoryImpl(this._remote);

  @override
  Future<List<Category>> getCategories() {
    return _remote.getCategories();
  }
}
