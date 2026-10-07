import 'package:flutter/foundation.dart';

abstract final class ImageUtils {
  /// Converts an external image URL to a CORS-friendly URL when running on Flutter Web.
  ///
  /// On Flutter Web (CanvasKit / HTML renderers), the browser enforces Cross-Origin
  /// Resource Sharing (CORS) when fetching image bytes for canvas rendering.
  /// CoinGecko CDN (assets.coingecko.com) does not send `Access-Control-Allow-Origin: *`,
  /// which causes the browser to block the image and trigger the fallback placeholder.
  ///
  /// wsrv.nl is an ultra-fast, Cloudflare-backed open-source image CDN cache that
  /// forwards the request with full `Access-Control-Allow-Origin: *` headers.
  static String getCORSFriendlyUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return '';
    }

    final trimmedUrl = url.trim();

    // If not Web, native HttpClient on iOS/Android/Desktop doesn't enforce browser CORS
    if (!kIsWeb) {
      return trimmedUrl;
    }

    // If already proxied, data URI, blob, or local asset, return as-is
    if (trimmedUrl.startsWith('data:') ||
        trimmedUrl.startsWith('blob:') ||
        trimmedUrl.startsWith('assets/') ||
        trimmedUrl.contains('wsrv.nl') ||
        trimmedUrl.contains('images.weserv.nl')) {
      return trimmedUrl;
    }

    // Only proxy HTTP/HTTPS URLs
    if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
      return 'https://wsrv.nl/?url=${Uri.encodeComponent(trimmedUrl)}';
    }

    return trimmedUrl;
  }
}
