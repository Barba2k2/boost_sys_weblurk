class UrlValidator {
  static const List<String> _allowedSchemes = ['http', 'https'];
  static const List<String> _allowedDomains = [
    'twitch.tv',
    'www.twitch.tv',
    'twitch.com',
    'www.twitch.com',
    'docs.google.com',
    'discord.gg',
    'forms.gle',
    'drive.google.com',
  ];

  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);

      if (!_allowedSchemes.contains(uri.scheme)) {
        return false;
      }

      if (!_isAllowedDomain(uri.host)) {
        return false;
      }

      if (_containsSuspiciousCharacters(url)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _isAllowedDomain(String host) {
    return _allowedDomains.any(
      (domain) => host == domain || host.endsWith('.$domain'),
    );
  }

  static bool _containsSuspiciousCharacters(String url) {
    final suspiciousPatterns = [
      'jndi:',
      'ldap:',
      'rmi:',
      'dns:',
      'corba:',
      'iiop:',
      'nds:',
      'nis:',
      'getObject',
      'lookup',
      'eval(',
      'exec(',
      'system(',
      'Runtime.getRuntime()',
      'ProcessBuilder',
    ];

    final lowerUrl = url.toLowerCase();
    return suspiciousPatterns.any(
      (pattern) => lowerUrl.contains(pattern.toLowerCase()),
    );
  }

  static String sanitizeUrl(String url) {
    if (url.isEmpty) return '';

    String sanitized = url;

    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    sanitized = sanitized.replaceAll('<', '');
    sanitized = sanitized.replaceAll('>', '');
    sanitized = sanitized.replaceAll('"', '');
    sanitized = sanitized.replaceAll("'", '');
    sanitized = sanitized.replaceAll('&', '');

    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    sanitized = sanitized.trim();

    return sanitized;
  }

  static String? validateAndSanitizeUrl(String url) {
    final sanitized = sanitizeUrl(url);

    if (sanitized.isEmpty) return null;

    if (!isValidUrl(sanitized)) return null;

    return sanitized;
  }

  static bool isTwitchUrl(String url) {
    if (!isValidUrl(url)) return false;

    try {
      final uri = Uri.parse(url);
      return uri.host.contains('twitch');
    } catch (e) {
      return false;
    }
  }

  static String? extractTwitchChannel(String url) {
    if (!isTwitchUrl(url)) return null;

    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        return pathSegments.first;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
