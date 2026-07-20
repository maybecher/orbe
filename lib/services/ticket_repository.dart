import 'dart:math';
import 'dart:typed_data';

import '../models/ticket.dart';
import '../models/ticket_category.dart';

/// Seeded category snapshots used only to build demo/mock ticket data
/// here. Kept in sync by hand with [MockCategoryRepository]'s seeds —
/// tickets embed a category snapshot at creation time rather than a live
/// reference, so this repository doesn't need to depend on that one.
const _categoryHardware = TicketCategory(id: 'hardware', name: 'Hardware');
const _categorySoftware = TicketCategory(id: 'software', name: 'Software');
const _categoryNetwork = TicketCategory(id: 'network', name: 'Rede');
const _categoryAccess = TicketCategory(id: 'access', name: 'Acesso');

/// Contract for ticket data sources. The UI and providers depend only on
/// this abstraction, so swapping [MockTicketRepository] for a Firestore
/// implementation later requires no changes above this layer.
abstract interface class TicketRepository {
  Future<List<Ticket>> fetchTickets({
    required String requesterId,
    required String requesterName,
  });

  Future<Ticket> createTicket({
    required String requesterId,
    required String requesterName,
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    Uint8List? attachmentBytes,
  });

  Future<Ticket> rateTicket({
    required String ticketId,
    required int stars,
    String? comment,
  });

  /// All tickets across every requester. Used by the admin dashboard for
  /// aggregate indicators.
  Future<List<Ticket>> fetchAllTickets();

  /// Changes a ticket's status. Used by the admin/technician when
  /// attending a ticket. Records [Ticket.resolvedAt] the first time a
  /// ticket moves to [TicketStatus.resolved].
  Future<Ticket> updateStatus({
    required String ticketId,
    required TicketStatus status,
  });
}

class _TicketTemplate {
  const _TicketTemplate(this.title, this.description, this.category);
  final String title;
  final String description;
  final TicketCategory category;
}

/// In-memory implementation used during development and for the portfolio
/// demo. Seeded with a few sample tickets for the demo account so the list
/// isn't empty on first run. Any other account that has never opened a
/// ticket gets a handful of random ones generated the first time its
/// tickets are fetched, so new accounts don't start with an empty list.
class MockTicketRepository implements TicketRepository {
  MockTicketRepository() {
    _tickets.addAll(_buildHistoricalTickets());
  }

  final List<Ticket> _tickets = [
    Ticket(
      id: 't1',
      title: 'Notebook não liga',
      description: 'O notebook não liga desde ontem à noite.',
      category: _categoryHardware,
      priority: TicketPriority.high,
      status: TicketStatus.inProgress,
      createdAt: DateTime(2026, 7, 15, 9, 30),
      requesterId: '1',
      requesterName: 'Demo Orbe',
    ),
    Ticket(
      id: 't2',
      title: 'Acesso ao sistema financeiro',
      description: 'Preciso de acesso ao módulo financeiro para o fechamento.',
      category: _categoryAccess,
      priority: TicketPriority.medium,
      status: TicketStatus.open,
      createdAt: DateTime(2026, 7, 16, 14, 5),
      requesterId: '1',
      requesterName: 'Demo Orbe',
    ),
    Ticket(
      id: 't3',
      title: 'Impressora do 3º andar sem toner',
      description: 'A impressora está imprimindo em branco.',
      category: _categoryHardware,
      priority: TicketPriority.low,
      status: TicketStatus.resolved,
      createdAt: DateTime(2026, 7, 10, 11, 0),
      requesterId: '1',
      requesterName: 'Demo Orbe',
      resolvedAt: DateTime(2026, 7, 11, 15, 30),
    ),
  ];

  static const Duration _latency = Duration(milliseconds: 600);
  int _sequence = 4;
  final Random _random = Random();

  static const List<_TicketTemplate> _templates = [
    _TicketTemplate(
      'Computador não liga',
      'O computador não liga desde a manhã, luz da fonte não acende.',
      _categoryHardware,
    ),
    _TicketTemplate(
      'Erro ao abrir o sistema de vendas',
      'O sistema trava com uma tela branca ao tentar emitir nota fiscal.',
      _categorySoftware,
    ),
    _TicketTemplate(
      'Sem conexão com a internet',
      'A conexão Wi-Fi cai a cada poucos minutos no meu setor.',
      _categoryNetwork,
    ),
    _TicketTemplate(
      'Solicitação de acesso à pasta compartilhada',
      'Preciso de acesso à pasta do setor financeiro para o fechamento mensal.',
      _categoryAccess,
    ),
    _TicketTemplate(
      'Monitor com tela piscando',
      'O monitor fica piscando aleatoriamente, principalmente pela manhã.',
      _categoryHardware,
    ),
    _TicketTemplate(
      'Impressora não reconhece o computador',
      'A impressora não aparece na lista de dispositivos disponíveis.',
      _categoryHardware,
    ),
    _TicketTemplate(
      'Lentidão no notebook',
      'O notebook está muito lento para abrir programas simples.',
      _categoryHardware,
    ),
    _TicketTemplate(
      'Redefinição de senha do sistema',
      'Esqueci minha senha de acesso e preciso redefinir.',
      _categoryAccess,
    ),
    _TicketTemplate(
      'Atualização de software não conclui',
      'A atualização trava em 80% e não conclui de forma alguma.',
      _categorySoftware,
    ),
    _TicketTemplate(
      'Solicitação de instalação de programa',
      'Preciso instalar o pacote de edição de imagens para o time de design.',
      _categorySoftware,
    ),
    _TicketTemplate(
      'VPN não conecta fora da empresa',
      'Não consigo conectar na VPN pelo notebook em home office.',
      _categoryNetwork,
    ),
    _TicketTemplate(
      'Teclado com teclas travando',
      'Algumas teclas do teclado precisam de mais força para funcionar.',
      _categoryHardware,
    ),
  ];

  static const List<String> _ratingComments = [
    'Atendimento rápido, resolveu no mesmo dia.',
    'Técnico muito atencioso, obrigado!',
    'Poderia ter sido um pouco mais rápido, mas resolveu.',
    'Excelente suporte, recomendo.',
  ];

  static const List<String> _historicalRequesterNames = [
    'Fernanda Lima',
    'Ricardo Souza',
    'Juliana Alves',
    'Marcos Pereira',
    'Camila Rocha',
    'Bruno Costa',
  ];

  /// Background history of already-resolved tickets spread across the
  /// last 12 months, so the admin dashboard's day/week/month/year charts
  /// have realistic data from the start. Attributed to synthetic past
  /// requesters (not any real account), so they never show up in anyone's
  /// personal ticket list — only in the admin's aggregate views.
  List<Ticket> _buildHistoricalTickets() {
    final now = DateTime.now();
    final tickets = <Ticket>[];

    for (var monthsAgo = 11; monthsAgo >= 0; monthsAgo--) {
      final monthDate = DateTime(now.year, now.month - monthsAgo, 1);
      final count = 2 + _random.nextInt(5);

      for (var i = 0; i < count; i++) {
        final template = _templates[_random.nextInt(_templates.length)];
        final requesterIndex = _random.nextInt(_historicalRequesterNames.length);
        final day = 1 + _random.nextInt(28);
        final resolvedAt = DateTime(
          monthDate.year,
          monthDate.month,
          day,
          8 + _random.nextInt(10),
        );
        final createdAt = resolvedAt.subtract(
          Duration(days: 1 + _random.nextInt(4)),
        );

        tickets.add(Ticket(
          id: 't${_sequence++}',
          title: template.title,
          description: template.description,
          category: template.category,
          priority: TicketPriority.values[_random.nextInt(TicketPriority.values.length)],
          status: TicketStatus.resolved,
          createdAt: createdAt,
          requesterId: 'seed-${requesterIndex + 1}',
          requesterName: _historicalRequesterNames[requesterIndex],
          resolvedAt: resolvedAt,
        ));
      }
    }
    return tickets;
  }

  @override
  Future<List<Ticket>> fetchTickets({
    required String requesterId,
    required String requesterName,
  }) async {
    await Future<void>.delayed(_latency);

    final hasTickets = _tickets.any((t) => t.requesterId == requesterId);
    if (!hasTickets) {
      _tickets.addAll(_generateRandomTickets(requesterId, requesterName));
    }

    final tickets = _tickets.where((t) => t.requesterId == requesterId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tickets;
  }

  List<Ticket> _generateRandomTickets(String requesterId, String requesterName) {
    final templates = List.of(_templates)..shuffle(_random);
    final count = 2 + _random.nextInt(3);

    return templates.take(count).map((template) {
      final status = TicketStatus.values[_random.nextInt(TicketStatus.values.length)];
      final priority =
          TicketPriority.values[_random.nextInt(TicketPriority.values.length)];
      final createdAt = DateTime.now().subtract(
        Duration(days: _random.nextInt(14), hours: _random.nextInt(24)),
      );
      final isResolved = status == TicketStatus.resolved;
      final isRated = isResolved && _random.nextBool();

      return Ticket(
        id: 't${_sequence++}',
        title: template.title,
        description: template.description,
        category: template.category,
        priority: priority,
        status: status,
        createdAt: createdAt,
        requesterId: requesterId,
        requesterName: requesterName,
        ratingStars: isRated ? 3 + _random.nextInt(3) : null,
        ratingComment:
            isRated ? _ratingComments[_random.nextInt(_ratingComments.length)] : null,
        resolvedAt: isResolved
            ? createdAt.add(Duration(hours: 2 + _random.nextInt(48)))
            : null,
      );
    }).toList();
  }

  @override
  Future<Ticket> createTicket({
    required String requesterId,
    required String requesterName,
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    Uint8List? attachmentBytes,
  }) async {
    await Future<void>.delayed(_latency);
    final ticket = Ticket(
      id: 't${_sequence++}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      priority: priority,
      status: TicketStatus.open,
      createdAt: DateTime.now(),
      requesterId: requesterId,
      requesterName: requesterName,
      attachmentBytes: attachmentBytes,
    );
    _tickets.add(ticket);
    return ticket;
  }

  @override
  Future<Ticket> rateTicket({
    required String ticketId,
    required int stars,
    String? comment,
  }) async {
    await Future<void>.delayed(_latency);
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) {
      throw StateError('Chamado não encontrado.');
    }
    final rated = _tickets[index].copyWith(
      ratingStars: stars,
      ratingComment: comment,
    );
    _tickets[index] = rated;
    return rated;
  }

  @override
  Future<List<Ticket>> fetchAllTickets() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_tickets);
  }

  @override
  Future<Ticket> updateStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    await Future<void>.delayed(_latency);
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) {
      throw StateError('Chamado não encontrado.');
    }
    final current = _tickets[index];
    final updated = current.copyWith(
      status: status,
      resolvedAt: status == TicketStatus.resolved && current.resolvedAt == null
          ? DateTime.now()
          : null,
    );
    _tickets[index] = updated;
    return updated;
  }
}
