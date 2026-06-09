import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'event_bus.dart';
import 'module.dart';
import 'redactor.dart';
import 'storage.dart';

/// Storage keys used by the core GrabKit runtime.
abstract final class GrabKitRuntimeStorageKeys {
  static const disabledModuleIds = 'grabkit_disabled_module_ids';
}

/// Owns installed GrabKit modules and shared diagnostic services.
class GrabKitRuntime extends ChangeNotifier {
  GrabKitRuntime({
    required List<GrabKitModule> modules,
    GrabKitEventBus? eventBus,
    GrabKitStorage? storage,
    this.redactor = defaultGrabKitRedactor,
  })  : modules = List.unmodifiable(modules),
        eventBus = eventBus ?? GrabKitEventBus(),
        storage = storage ?? GrabKitMemoryStorage();

  final List<GrabKitModule> modules;
  final GrabKitEventBus eventBus;
  final GrabKitStorage storage;
  final GrabKitRedactor redactor;
  final Set<String> _disabledModuleIds = {};
  bool _initialized = false;

  bool get initialized => _initialized;

  List<GrabKitModule> get enabledModules => modules
      .where((module) => !_disabledModuleIds.contains(module.id))
      .toList(growable: false);

  List<GrabKitPanel> get panels =>
      enabledModules.expand((module) => module.buildPanels()).toList();

  Future<void> initialize() async {
    if (_initialized) return;
    await _restoreDisabledModules();
    for (final module in modules) {
      if (!_hasPersistedModuleState && !module.enabledByDefault) {
        _disabledModuleIds.add(module.id);
      }
      await module.initialize(this);
    }
    _initialized = true;
    notifyListeners();
  }

  bool isModuleEnabled(String id) => !_disabledModuleIds.contains(id);

  void setModuleEnabled(String id, bool enabled) {
    enabled ? _disabledModuleIds.remove(id) : _disabledModuleIds.add(id);
    unawaited(_persistDisabledModules());
    notifyListeners();
  }

  T module<T extends GrabKitModule>() => modules.whereType<T>().single;

  @override
  void dispose() {
    for (final module in modules.reversed) {
      module.dispose();
    }
    eventBus.dispose();
    super.dispose();
  }

  bool _hasPersistedModuleState = false;

  Future<void> _restoreDisabledModules() async {
    final value =
        await storage.read(GrabKitRuntimeStorageKeys.disabledModuleIds);
    if (value == null) return;
    _hasPersistedModuleState = true;
    _disabledModuleIds
      ..clear()
      ..addAll(_decodeModuleIds(value));
  }

  Future<void> _persistDisabledModules() async {
    await storage.write(
      GrabKitRuntimeStorageKeys.disabledModuleIds,
      jsonEncode(_disabledModuleIds.toList()..sort()),
    );
  }

  Iterable<String> _decodeModuleIds(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<String>();
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }
}
