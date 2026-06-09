class GrabKitEnvironmentPreset {
  const GrabKitEnvironmentPreset({
    required this.label,
    required this.baseUrl,
    String? realtimeUrl,
    String? mqttUrl,
  }) : realtimeUrl = realtimeUrl ?? mqttUrl ?? '';

  final String label;
  final String baseUrl;
  final String realtimeUrl;

  @Deprecated('Use realtimeUrl')
  String get mqttUrl => realtimeUrl;
}

abstract final class GrabKitEnvironmentKeys {
  static const baseUrlOverride = 'grabkit_base_url_override';
  static const realtimeUrlOverride = 'grabkit_mqtt_broker_url_override';

  @Deprecated('Use realtimeUrlOverride')
  static const mqttBrokerUrlOverride = realtimeUrlOverride;
}

typedef DevToolsPrefsKeys = GrabKitEnvironmentKeys;
