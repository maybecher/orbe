/// Reusable form validators shared across the auth screens.
///
/// Each returns `null` when the value is valid or an error message to be
/// shown by a [TextFormField]. Keeping them here avoids duplicating the
/// same rules on every form.
class Validators {
  const Validators._();

  static final RegExp _emailPattern =
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? required(String? value, {String field = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório.';
    }
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, field: 'E-mail');
    if (empty != null) return empty;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  static String? password(String? value) {
    final empty = required(value, field: 'Senha');
    if (empty != null) return empty;
    if (value!.length < 6) {
      return 'A senha deve ter ao menos 6 caracteres.';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Confirme a senha.';
      }
      if (value != original()) {
        return 'As senhas não coincidem.';
      }
      return null;
    };
  }
}
