import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../styles/app_colors.dart';
import '../utils/text_initials.dart';

/// Admin "Gerenciar usuários": every registered account, with the ability
/// to remove one.
class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersControllerProvider);
    final currentUserId = ref.watch(authControllerProvider).value?.id;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(
            'Não foi possível carregar os usuários.',
            style: text.bodyMedium,
          ),
        ),
        data: (users) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = users[index];
            final isSelf = user.id == currentUserId;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initialsFor(user.name),
                    style: const TextStyle(color: AppColors.textOnPrimary),
                  ),
                ),
                title: Text(user.name),
                subtitle: Text('${user.email} · ${user.role.label}'),
                trailing: isSelf
                    ? null
                    : IconButton(
                        tooltip: 'Remover conta',
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _confirmDelete(context, ref, user),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover conta?'),
        content: Text('Isso vai remover a conta de ${user.name} permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminUsersControllerProvider.notifier).deleteUser(user.id);
    }
  }
}
