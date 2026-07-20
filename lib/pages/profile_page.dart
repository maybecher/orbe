import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/external_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/external_profile_provider.dart';
import '../styles/app_colors.dart';
import '../utils/network_image_url.dart';
import '../utils/text_initials.dart';
import '../widgets/custom_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final externalProfile = ref.watch(externalProfileProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  backgroundImage: externalProfile != null
                      ? NetworkImage(webSafeImageUrl(externalProfile.avatarUrl))
                      : null,
                  onBackgroundImageError: externalProfile != null
                      ? (_, _) {}
                      : null,
                  child: externalProfile == null
                      ? Text(
                          initialsFor(user?.name ?? '?'),
                          style: text.headlineMedium?.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(user?.name ?? '', style: text.titleLarge),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: text.bodyMedium),
                const SizedBox(height: 8),
                if (user != null)
                  Chip(
                    label: Text(user.role.label),
                    backgroundColor:
                        AppColors.secondary.withValues(alpha: 0.12),
                    labelStyle: text.labelLarge?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
              ],
            ),
          ),
          if (externalProfile != null) ...[
            const SizedBox(height: 24),
            _ExternalInfoCard(profile: externalProfile),
          ],
          const SizedBox(height: 32),
          CustomButton(
            label: 'Sair',
            variant: ButtonVariant.outline,
            icon: Icons.logout_rounded,
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _ExternalInfoCard extends StatelessWidget {
  const _ExternalInfoCard({required this.profile});

  final ExternalProfile profile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(icon: Icons.phone_outlined, label: profile.phone),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: '${profile.city}, ${profile.country}',
            ),
            const SizedBox(height: 8),
            Text(
              'Dados ilustrativos gerados automaticamente.',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    );
  }
}
