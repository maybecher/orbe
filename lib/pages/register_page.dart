import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/external_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/external_profile_provider.dart';
import '../services/auth_repository.dart';
import '../styles/app_colors.dart';
import '../utils/network_image_url.dart';
import '../utils/validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  ExternalProfile? _generatedProfile;
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _generateFromApi() async {
    setState(() => _isGenerating = true);
    try {
      final profile =
          await ref.read(externalProfileRepositoryProvider).fetchRandomProfile();
      if (!mounted) return;
      setState(() {
        _generatedProfile = profile;
        _nameController.text = profile.fullName;
        _emailController.text = profile.email;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível buscar um usuário. Tente novamente.'),
        ));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          externalProfile: _generatedProfile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(error: (error, _) => _showError(error));
    });

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Criar conta',
                      subtitle: 'Leva menos de um minuto.',
                    ),
                    const SizedBox(height: 32),
                    _generatedProfile == null
                        ? OutlinedButton.icon(
                            onPressed: _isGenerating ? null : _generateFromApi,
                            icon: _isGenerating
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome_outlined),
                            label: Text(
                              _isGenerating ? 'Buscando...' : 'Gerar usuário da API',
                            ),
                          )
                        : _GeneratedProfilePreview(
                            profile: _generatedProfile!,
                            isGenerating: _isGenerating,
                            onRegenerate: _generateFromApi,
                          ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Nome completo',
                      hint: 'Seu nome',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.required(v, field: 'Nome'),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'E-mail',
                      hint: 'seu@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Senha',
                      hint: '••••••',
                      controller: _passwordController,
                      obscure: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Confirmar senha',
                      hint: '••••••',
                      controller: _confirmController,
                      obscure: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      validator: Validators.confirmPassword(
                        () => _passwordController.text,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      label: 'Cadastrar',
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    _LoginPrompt(onTap: () => context.pop()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showError(Object error) {
    final message = error is AuthException
        ? error.message
        : 'Não foi possível criar a conta.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GeneratedProfilePreview extends StatelessWidget {
  const _GeneratedProfilePreview({
    required this.profile,
    required this.isGenerating,
    required this.onRegenerate,
  });

  final ExternalProfile profile;
  final bool isGenerating;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(webSafeImageUrl(profile.avatarUrl)),
            onBackgroundImageError: (_, _) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  profile.email,
                  style: text.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Gerar outro',
            onPressed: isGenerating ? null : onRegenerate,
            icon: isGenerating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Já tem conta?', style: Theme.of(context).textTheme.bodyMedium),
        TextButton(onPressed: onTap, child: const Text('Entrar')),
      ],
    );
  }
}
