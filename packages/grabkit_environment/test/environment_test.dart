import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_environment/grabkit_environment.dart';

void main() {
  test('module declares environment settings metadata', () {
    final metadata = GrabKitEnvironmentModule(
      environmentName: 'qa',
      defaultBaseUrl: 'https://api.example.com',
      defaultRealtimeUrl: 'wss://example.com',
    ).metadata;

    expect(metadata.capturesEvents, isFalse);
    expect(metadata.contributesToReports, isTrue);
    expect(metadata.hasSettings, isTrue);
    expect(metadata.dataCategories, {GrabKitDataCategory.environment});
  });

  test('preset exposes realtime URL', () {
    const preset = GrabKitEnvironmentPreset(
      label: 'QA',
      baseUrl: 'https://api.example.com',
      realtimeUrl: 'wss://example.com',
    );
    expect(preset.realtimeUrl, 'wss://example.com');
  });
}
