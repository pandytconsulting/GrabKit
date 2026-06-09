import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit/grabkit.dart';

void main() {
  test('runtime initializes and toggles modules', () async {
    final module = _TestModule();
    final runtime = GrabKitRuntime(modules: [module]);

    await runtime.initialize();
    expect(module.initialized, isTrue);
    expect(runtime.enabledModules, [module]);

    runtime.setModuleEnabled(module.id, false);
    expect(runtime.enabledModules, isEmpty);
  });

  test('runtime uses enabledByDefault when no module state is persisted',
      () async {
    final runtime = GrabKitRuntime(
      modules: [
        _TestModule(id: 'enabled'),
        _TestModule(id: 'disabled', enabledByDefault: false),
      ],
    );

    await runtime.initialize();

    expect(runtime.isModuleEnabled('enabled'), isTrue);
    expect(runtime.isModuleEnabled('disabled'), isFalse);

    runtime.dispose();
  });

  test('runtime restores persisted disabled module ids', () async {
    final storage = GrabKitMemoryStorage();
    await storage.write(
      GrabKitRuntimeStorageKeys.disabledModuleIds,
      '["logs"]',
    );
    final runtime = GrabKitRuntime(
      storage: storage,
      modules: [
        _TestModule(id: 'logs'),
        _TestModule(id: 'network'),
        _TestModule(id: 'experimental', enabledByDefault: false),
      ],
    );

    await runtime.initialize();

    expect(runtime.isModuleEnabled('logs'), isFalse);
    expect(runtime.isModuleEnabled('network'), isTrue);
    expect(runtime.isModuleEnabled('experimental'), isTrue);

    runtime.dispose();
  });

  test('runtime persists module enabled changes', () async {
    final storage = GrabKitMemoryStorage();
    final runtime = GrabKitRuntime(
      storage: storage,
      modules: [
        _TestModule(id: 'logs'),
        _TestModule(id: 'network'),
      ],
    );
    await runtime.initialize();

    runtime.setModuleEnabled('network', false);
    await Future<void>.delayed(Duration.zero);

    expect(
      await storage.read(GrabKitRuntimeStorageKeys.disabledModuleIds),
      '["network"]',
    );

    runtime.setModuleEnabled('network', true);
    await Future<void>.delayed(Duration.zero);

    expect(
      await storage.read(GrabKitRuntimeStorageKeys.disabledModuleIds),
      '[]',
    );

    runtime.dispose();
  });

  test('about module contributes an informational panel', () {
    final panels = GrabKitAboutModule().buildPanels();

    expect(panels.single.id, 'about.info');
    expect(panels.single.title, 'About');
  });

  test('modules expose default metadata', () {
    final metadata = _TestModule().metadata;

    expect(metadata.capturesEvents, isFalse);
    expect(metadata.contributesToReports, isFalse);
    expect(metadata.hasSettings, isFalse);
    expect(metadata.dataCategories, isEmpty);
  });

  test('about module declares non-capturing metadata', () {
    final metadata = GrabKitAboutModule().metadata;

    expect(metadata.capturesEvents, isFalse);
    expect(metadata.contributesToReports, isFalse);
    expect(metadata.hasSettings, isFalse);
    expect(metadata.dataCategories, isEmpty);
  });
}

class _TestModule extends GrabKitModule {
  _TestModule({
    this.id = 'test',
    this.enabledByDefault = true,
  });

  bool initialized = false;

  @override
  final String id;

  @override
  String get displayName => 'Test';

  @override
  final bool enabledByDefault;

  @override
  List<GrabKitPanel> buildPanels() => const [];

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize(GrabKitRuntime runtime) async => initialized = true;
}
