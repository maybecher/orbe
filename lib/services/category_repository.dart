import '../models/ticket_category.dart';

/// Contract for managing ticket categories. The UI and providers depend
/// only on this abstraction, so swapping [MockCategoryRepository] for a
/// Firestore implementation later requires no changes above this layer.
abstract interface class CategoryRepository {
  Future<List<TicketCategory>> fetchCategories();

  Future<TicketCategory> createCategory(String name);

  Future<TicketCategory> renameCategory(String id, String name);

  Future<void> deleteCategory(String id);
}

/// In-memory implementation, seeded with Orbe's default categories.
class MockCategoryRepository implements CategoryRepository {
  final List<TicketCategory> _categories = const [
    TicketCategory(id: 'hardware', name: 'Hardware'),
    TicketCategory(id: 'software', name: 'Software'),
    TicketCategory(id: 'network', name: 'Rede'),
    TicketCategory(id: 'access', name: 'Acesso'),
    TicketCategory(id: 'other', name: 'Outros'),
  ].toList();

  static const Duration _latency = Duration(milliseconds: 400);
  int _sequence = 1;

  @override
  Future<List<TicketCategory>> fetchCategories() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_categories);
  }

  @override
  Future<TicketCategory> createCategory(String name) async {
    await Future<void>.delayed(_latency);
    final category = TicketCategory(id: 'custom-${_sequence++}', name: name.trim());
    _categories.add(category);
    return category;
  }

  @override
  Future<TicketCategory> renameCategory(String id, String name) async {
    await Future<void>.delayed(_latency);
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw StateError('Categoria não encontrada.');
    }
    final renamed = TicketCategory(id: id, name: name.trim());
    _categories[index] = renamed;
    return renamed;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future<void>.delayed(_latency);
    _categories.removeWhere((c) => c.id == id);
  }
}
