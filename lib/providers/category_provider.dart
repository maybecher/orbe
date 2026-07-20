import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket_category.dart';
import '../services/category_repository.dart';

/// Provides the active [CategoryRepository]. Swap the implementation here
/// (e.g. to Firestore) without touching the UI.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return MockCategoryRepository();
});

/// Holds the list of ticket categories. Used both by the "Abrir chamado"
/// form (as options) and the admin "Gerenciar categorias" screen (as
/// editable entries).
class CategoriesController extends AsyncNotifier<List<TicketCategory>> {
  @override
  Future<List<TicketCategory>> build() async {
    return ref.read(categoryRepositoryProvider).fetchCategories();
  }

  Future<void> createCategory(String name) async {
    if (name.trim().isEmpty) return;
    final repository = ref.read(categoryRepositoryProvider);
    final category = await repository.createCategory(name);
    state = AsyncValue.data([...?state.value, category]);
  }

  Future<void> renameCategory(String id, String name) async {
    if (name.trim().isEmpty) return;
    final repository = ref.read(categoryRepositoryProvider);
    final renamed = await repository.renameCategory(id, name);
    final current = state.value ?? const [];
    state = AsyncValue.data([
      for (final category in current)
        if (category.id == id) renamed else category,
    ]);
  }

  Future<void> deleteCategory(String id) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.deleteCategory(id);
    final current = state.value ?? const [];
    state = AsyncValue.data(current.where((c) => c.id != id).toList());
  }
}

final categoriesControllerProvider =
    AsyncNotifierProvider<CategoriesController, List<TicketCategory>>(
  CategoriesController.new,
);
