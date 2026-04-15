import 'package:votera_app/features/category/data/datasources/category_remote_datasource.dart';
import 'package:votera_app/features/category/data/models/category_model.dart';
import 'package:votera_app/features/category/domain/entities/category_entity.dart';
import 'package:votera_app/features/category/domain/repositories/icategory_repository.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  CategoryRepositoryImpl(this._dataSource);

  final CategoryRemoteDataSource _dataSource;

  @override
  Future<List<CategoryEntity>> getCategories(int workspaceId) async {
    final list = await _dataSource.fetchCategories(workspaceId);
    return list.map(CategoryModel.fromJson).toList();
  }
}
