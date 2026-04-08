enum SyncMode { local, cloud }

class ConfigModel {
  final SyncMode syncMode;
  final String apiKey;

  ConfigModel({
    required this.syncMode,
    required this.apiKey,
  });
}