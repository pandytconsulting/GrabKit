import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';

import 'environment_preset.dart';

class GrabKitEnvironmentModule extends GrabKitModule {
  GrabKitEnvironmentModule({
    required this.environmentName,
    required this.defaultBaseUrl,
    required this.defaultRealtimeUrl,
    this.presets = const [],
    this.onOverridesPersisted,
  });

  final String environmentName;
  final String defaultBaseUrl;
  final String defaultRealtimeUrl;
  final List<GrabKitEnvironmentPreset> presets;
  final Future<void> Function()? onOverridesPersisted;
  GrabKitRuntime? _runtime;

  @override
  String get id => 'environment';

  @override
  String get displayName => 'Environment';

  @override
  GrabKitModuleMetadata get metadata => const GrabKitModuleMetadata(
        contributesToReports: true,
        hasSettings: true,
        dataCategories: {GrabKitDataCategory.environment},
      );

  @override
  Future<void> initialize(GrabKitRuntime runtime) async => _runtime = runtime;

  @override
  Future<void> dispose() async {}

  @override
  List<GrabKitPanel> buildPanels() => [
        GrabKitPanel(
          id: 'environment.settings',
          title: 'Environment',
          icon: Icons.tune,
          builder: (_) => _EnvironmentPanel(module: this),
        ),
      ];
}

class _EnvironmentPanel extends StatefulWidget {
  const _EnvironmentPanel({required this.module});

  final GrabKitEnvironmentModule module;

  @override
  State<_EnvironmentPanel> createState() => _EnvironmentPanelState();
}

class _EnvironmentPanelState extends State<_EnvironmentPanel> {
  late final TextEditingController _baseUrl;
  late final TextEditingController _realtimeUrl;
  bool _loading = true;
  bool _restartRequired = false;

  @override
  void initState() {
    super.initState();
    _baseUrl = TextEditingController(text: widget.module.defaultBaseUrl);
    _realtimeUrl =
        TextEditingController(text: widget.module.defaultRealtimeUrl);
    _load();
  }

  Future<void> _load() async {
    final storage = widget.module._runtime!.storage;
    _baseUrl.text =
        await storage.read(GrabKitEnvironmentKeys.baseUrlOverride) ??
            widget.module.defaultBaseUrl;
    _realtimeUrl.text =
        await storage.read(GrabKitEnvironmentKeys.realtimeUrlOverride) ??
            widget.module.defaultRealtimeUrl;
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final storage = widget.module._runtime!.storage;
    await storage.write(
        GrabKitEnvironmentKeys.baseUrlOverride, _baseUrl.text.trim());
    await storage.write(
      GrabKitEnvironmentKeys.realtimeUrlOverride,
      _realtimeUrl.text.trim(),
    );
    await widget.module.onOverridesPersisted?.call();
    if (mounted) setState(() => _restartRequired = true);
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _realtimeUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Build environment: ${widget.module.environmentName}'),
        if (_restartRequired)
          Text(
            'Restart required to apply changes.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (widget.module.presets.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final preset in widget.module.presets)
                ActionChip(
                  label: Text(preset.label),
                  onPressed: () => setState(() {
                    _baseUrl.text = preset.baseUrl;
                    _realtimeUrl.text = preset.realtimeUrl;
                  }),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _baseUrl,
          decoration: const InputDecoration(
            labelText: 'API base URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _realtimeUrl,
          decoration: const InputDecoration(
            labelText: 'Realtime URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Save overrides')),
      ],
    );
  }
}
