import 'package:flutter/foundation.dart';

/// Wraps [url] through a CORS-friendly image proxy when running on Flutter
/// Web. Browsers block canvas rendering of cross-origin images that don't
/// send CORS headers — randomuser.me's photo CDN doesn't send any — so on
/// web we route through images.weserv.nl, which does. Native platforms
/// fetch images directly since CORS doesn't apply there.
String webSafeImageUrl(String url) {
  if (!kIsWeb) return url;
  return Uri.https('images.weserv.nl', '/', {'url': url}).toString();
}
