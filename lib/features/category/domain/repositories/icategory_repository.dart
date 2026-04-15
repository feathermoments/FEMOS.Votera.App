import 'package:votera_app/features/category/domain/entities/category_entity.dart';

abstract interface class ICategoryRepository {
  Future<List<CategoryEntity>> getCategories(int workspaceId);
}
