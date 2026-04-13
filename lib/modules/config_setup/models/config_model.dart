// lib/modules/config_setup/models/config_model.dart

enum SyncMode { local, cloud }

class ConfigModel {
  final SyncMode syncMode;
  final String apiKey;
  final String entryIp;
  final int entryPort;
  final String exitIp;
  final int exitPort;
  final String siteName;

  ConfigModel({
    required this.syncMode,
    required this.apiKey,
    required this.entryIp,
    required this.entryPort,
    required this.exitIp,
    required this.exitPort,
    required this.siteName,
  });

  Map<String, dynamic> toJson() => {
        // Convert enum to string for safe storage
        'syncMode': syncMode.name, 
        'apiKey': apiKey,
        'entryIp': entryIp,
        'entryPort': entryPort,
        'exitIp': exitIp,
        'exitPort': exitPort,
        'siteName': siteName,
      };

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the string back into the SyncMode enum
    final savedMode = json['syncMode'] as String?;
    final mode = SyncMode.values.firstWhere(
      (e) => e.name == savedMode,
      orElse: () => SyncMode.cloud, // Default fallback
    );

    return ConfigModel(
      syncMode: mode,
      apiKey: json['apiKey'] ?? '',
      entryIp: json['entryIp'] ?? '192.168.8.230',
      entryPort: json['entryPort'] ?? 8008,
      exitIp: json['exitIp'] ?? '192.168.8.231',
      exitPort: json['exitPort'] ?? 8009,
      siteName: json['siteName'] ?? 'LA SALLE',
    );
  }
}