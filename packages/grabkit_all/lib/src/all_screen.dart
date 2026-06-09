import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_environment/grabkit_environment.dart';
import 'package:grabkit_export/grabkit_export.dart';
import 'package:grabkit_logs/grabkit_logs.dart';
import 'package:grabkit_network/grabkit_network.dart';
import 'package:grabkit_realtime/grabkit_realtime.dart';

import 'shared_preferences_storage.dart';

/// Standard all-module GrabKit screen for teams that prefer one installation.
class GrabKitScreen extends StatefulWidget {
  const GrabKitScreen({
    super.key,
    required this.compileTimeEnv,
    required this.compileTimeBaseUrl,
    required this.compileTimeMqttUrl,
    this.environmentPresets = const [],
    this.sessionSummary,
    this.onOverridesPersisted,
  });

  static const routeName = '/dev-tools';

  final String compileTimeEnv;
  final String compileTimeBaseUrl;
  final String compileTimeMqttUrl;
  final List<GrabKitEnvironmentPreset> environmentPresets;
  final String? sessionSummary;
  final Future<void> Function()? onOverridesPersisted;

  @override
  State<GrabKitScreen> createState() => _GrabKitScreenState();
}

class _GrabKitScreenState extends State<GrabKitScreen> {
  late final GrabKitRuntime runtime;

  @override
  void initState() {
    super.initState();
    runtime = GrabKitRuntime(
      storage: GrabKitSharedPreferencesStorage(),
      modules: [
        GrabKitNetworkModule(),
        GrabKitLogsModule(),
        GrabKitRealtimeModule(),
        GrabKitEnvironmentModule(
          environmentName: widget.compileTimeEnv,
          defaultBaseUrl: widget.compileTimeBaseUrl,
          defaultRealtimeUrl: widget.compileTimeMqttUrl,
          presets: widget.environmentPresets,
          onOverridesPersisted: widget.onOverridesPersisted,
        ),
        GrabKitExportModule(
          environmentName: widget.compileTimeEnv,
          sessionSummary: widget.sessionSummary,
        ),
        GrabKitAboutModule(),
      ],
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GrabKitShell(runtime: runtime);
}
