/// A ticket category. Unlike [TicketPriority]/[TicketStatus], categories
/// are administrator-managed (create/rename/remove), so this is a plain
/// data class instead of an enum.
class TicketCategory {
  const TicketCategory({required this.id, required this.name});

  final String id;
  final String name;
}
