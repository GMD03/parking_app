// lib/modules/config_setup/models/config_model.dart

enum SyncMode { local, cloud }

class ConfigModel {
  final SyncMode syncMode;
  final String apiKey;

  ConfigModel({
    required this.syncMode,
    required this.apiKey,
  });

  Map<String, dynamic> toJson() => {
        // Convert enum to string for safe storage
        'syncMode': syncMode.name, 
        'apiKey': apiKey,
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
    );
  }
}