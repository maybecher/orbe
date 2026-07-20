/// Centralized asset path constants.
///
/// Referencing paths through here avoids magic strings and typos when
/// loading bundled images across the app.
class AppAssets {
  const AppAssets._();

  /// Full brand lockup (orbit mark + "orbe" wordmark), transparent background.
  static const String logoFull = 'lib/assets/images/logo_orbe_full.png';

  /// Orbit mark only, transparent background. Used in compact contexts.
  static const String logoMark = 'lib/assets/images/logo_orbe_mark.png';
}
