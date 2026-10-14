class SupportChatRealtimeConfig {
  const SupportChatRealtimeConfig({
    required this.enabled,
    required this.key,
    required this.host,
    required this.scheme,
    required this.port,
  });

  final bool enabled;
  final String? key;
  final String? host;
  final String scheme;
  final int port;

  factory SupportChatRealtimeConfig.fromJson(Map<String, dynamic> json) {
    final dynamic rawEnabled = json['enabled'];
    final dynamic rawKey = json['key'];
    final dynamic rawHost = json['host'];
    final dynamic rawScheme = json['scheme'];
    final dynamic rawPort = json['port'];
    final int? port = rawPort is int ? rawPort : int.tryParse('$rawPort');

    if (rawEnabled is! bool ||
        rawScheme is! String ||
        port == null ||
        (rawEnabled && (rawKey is! String || rawHost is! String))) {
      throw const FormatException('Support chat realtime config is invalid.');
    }

    return SupportChatRealtimeConfig(
      enabled: rawEnabled,
      key: rawKey is String ? rawKey : null,
      host: rawHost is String ? rawHost : null,
      scheme: rawScheme,
      port: port,
    );
  }
}
