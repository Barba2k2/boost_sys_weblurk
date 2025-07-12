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

  /// Valida se uma URL é segura e permitida
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);

      // Verifica se o scheme é permitido
      if (!_allowedSchemes.contains(uri.scheme)) {
        return false;
      }

      // Verifica se o host é permitido
      if (!_isAllowedDomain(uri.host)) {
        return false;
      }

      // Verifica se não há caracteres suspeitos
      if (_containsSuspiciousCharacters(url)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o domínio é permitido
  static bool _isAllowedDomain(String host) {
    return _allowedDomains.any(
      (domain) => host == domain || host.endsWith('.$domain'),
    );
  }

  /// Verifica se a URL contém caracteres suspeitos de ataques
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

  /// Sanitiza uma URL removendo caracteres perigosos
  static String sanitizeUrl(String url) {
    if (url.isEmpty) return '';

    String sanitized = url;

    // Remove caracteres de controle
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Remove caracteres suspeitos de injeção
    sanitized = sanitized.replaceAll('<', '');
    sanitized = sanitized.replaceAll('>', '');
    sanitized = sanitized.replaceAll('"', '');
    sanitized = sanitized.replaceAll("'", '');
    sanitized = sanitized.replaceAll('&', '');

    // Remove múltiplos espaços
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Remove espaços no início e fim
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Valida e sanitiza uma URL, retornando null se inválida
  static String? validateAndSanitizeUrl(String url) {
    final sanitized = sanitizeUrl(url);

    if (sanitized.isEmpty) return null;

    if (!isValidUrl(sanitized)) return null;

    return sanitized;
  }

  /// Verifica se uma URL é uma URL do Twitch válida
  static bool isTwitchUrl(String url) {
    if (!isValidUrl(url)) return false;

    try {
      final uri = Uri.parse(url);
      return uri.host.contains('twitch');
    } catch (e) {
      return false;
    }
  }

  /// Extrai o nome do canal de uma URL do Twitch
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
