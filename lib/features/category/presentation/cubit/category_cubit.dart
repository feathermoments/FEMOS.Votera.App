import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/features/category/domain/entities/category_entity.dart';
import 'package:votera_app/features/category/domain/repositories/icategory_repository.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  const CategoryLoaded(this.categories);

  final List<CategoryEntity> categories;
}

class CategoryError extends CategoryState {
  const CategoryError(this.message);

  final String message;
}

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(const CategoryInitial()) {
    _repository = sl<ICategoryRepository>();
  }

  late final ICategoryRepository _repository;

  Future<void> loadCategories(int workspaceId) async {
    emit(const CategoryLoading());
    try {
      final categories = await _repository.getCategories(workspaceId);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
