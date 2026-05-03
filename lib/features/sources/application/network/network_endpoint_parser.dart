class ParsedWebDavEndpoint {
  const ParsedWebDavEndpoint({
    required this.host,
    required this.remotePath,
    required this.secure,
    this.port,
  });

  final String host;
  final String remotePath;
  final bool secure;
  final int? port;
}

class ParsedSmbEndpoint {
  const ParsedSmbEndpoint({
    required this.host,
    required this.remotePath,
    this.port,
  });

  final String host;
  final String remotePath;
  final int? port;
}

String unexpectedWebDavMessage(Object error, {required String fallback}) {
  var message = error.toString().trim();
  if (message.startsWith('Exception: ')) {
    message = message.substring('Exception: '.length);
  }
  if (message.isEmpty || message == 'null') {
    return fallback;
  }
  return message;
}

String unexpectedSmbMessage(Object error, {required String fallback}) {
  var message = error.toString().trim();
  if (message.startsWith('Exception: ')) {
    message = message.substring('Exception: '.length);
  }
  if (message.isEmpty || message == 'null') {
    return fallback;
  }
  return message;
}

ParsedWebDavEndpoint parseWebDavEndpoint({
  required String hostInput,
  required String portInput,
  required String pathInput,
  required bool secure,
}) {
  final trimmedHost = hostInput.trim();
  final explicitPort = int.tryParse(portInput.trim());
  final trimmedPath = pathInput.trim();

  if (trimmedHost.startsWith('http://') || trimmedHost.startsWith('https://')) {
    final uri = Uri.tryParse(trimmedHost);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return ParsedWebDavEndpoint(
        host: trimmedHost,
        remotePath: trimmedPath,
        secure: secure,
        port: explicitPort,
      );
    }

    final normalizedPath = trimmedPath.isNotEmpty
        ? trimmedPath
        : (uri.path.isEmpty ? '/' : uri.path);
    return ParsedWebDavEndpoint(
      host: uri.host,
      remotePath: normalizedPath,
      secure: uri.scheme == 'https',
      port: explicitPort ?? (uri.hasPort ? uri.port : null),
    );
  }

  final split = splitHostAndPort(trimmedHost);
  return ParsedWebDavEndpoint(
    host: split.host,
    remotePath: trimmedPath,
    secure: secure,
    port: explicitPort ?? split.port,
  );
}

ParsedSmbEndpoint parseSmbEndpoint({
  required String hostInput,
  required String portInput,
  required String pathInput,
}) {
  final trimmedHost = hostInput.trim();
  final explicitPort = int.tryParse(portInput.trim());
  final trimmedPath = pathInput.trim();

  if (trimmedHost.startsWith('smb://')) {
    final uri = Uri.tryParse(trimmedHost);
    if (uri != null && uri.scheme == 'smb') {
      final normalizedPath = trimmedPath.isNotEmpty
          ? trimmedPath
          : (uri.path.isEmpty ? '/' : uri.path);
      return ParsedSmbEndpoint(
        host: uri.host,
        remotePath: normalizedPath,
        port: explicitPort ?? (uri.hasPort ? uri.port : null),
      );
    }
  }

  final split = splitHostAndPort(trimmedHost);
  final normalizedPath = trimmedPath.isEmpty
      ? '/'
      : (trimmedPath.startsWith('/') ? trimmedPath : '/$trimmedPath');
  return ParsedSmbEndpoint(
    host: split.host,
    remotePath: normalizedPath,
    port: explicitPort ?? split.port,
  );
}

({String host, int? port}) splitHostAndPort(String input) {
  final trimmed = input.trim();
  final lastColon = trimmed.lastIndexOf(':');
  if (lastColon <= 0 || lastColon == trimmed.length - 1) {
    return (host: trimmed, port: null);
  }

  final host = trimmed.substring(0, lastColon);
  final port = int.tryParse(trimmed.substring(lastColon + 1));
  if (port == null) {
    return (host: trimmed, port: null);
  }

  return (host: host, port: port);
}