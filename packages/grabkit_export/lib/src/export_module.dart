import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_logs/grabkit_logs.dart';
import 'package:grabkit_network/grabkit_network.dart';
import 'package:grabkit_realtime/grabkit_realtime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'report_formatter.dart';

class GrabKitExportModule extends GrabKitModule {
  GrabKitExportModule({
    required this.environmentName,
    this.sessionSummary,
    GrabKitNetworkStore? networkStore,
    GrabKitLogStore? logStore,
    GrabKitRealtimeStore? realtimeStore,
  })  : networkStore = networkStore ?? GrabKitNetworkStore.instance,
        logStore = logStore ?? GrabKitLogStore.instance,
        realtimeStore = realtimeStore ?? GrabKitRealtimeStore.instance;

  final String environmentName;
  final String? sessionSummary;
  final GrabKitNetworkStore networkStore;
  final GrabKitLogStore logStore;
  final GrabKitRealtimeStore realtimeStore;

  @override
  String get id => 'export';

  @override
  String get displayName => 'Export';

  @override
  GrabKitModuleMetadata get metadata => const GrabKitModuleMetadata(
        contributesToReports: true,
        dataCategories: {
          GrabKitDataCategory.appInfo,
          GrabKitDataCategory.deviceInfo,
          GrabKitDataCategory.environment,
          GrabKitDataCategory.logs,
          GrabKitDataCategory.network,
          GrabKitDataCategory.realtime,
        },
      );

  @override
  Future<void> initialize(GrabKitRuntime runtime) async {}

  @override
  Future<void> dispose() async {}

  Future<String> buildReport() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    final diagnostics = GrabKitReportFormatter.build(
      GrabKitReportInput(
        environmentName: environmentName,
        sessionSummary: sessionSummary,
        networkCalls: networkStore.entries,
        logs: logStore.entries,
        realtimeEvents: realtimeStore.entries,
      ),
    );
    return 'App: ${packageInfo.packageName} '
        '${packageInfo.version} (${packageInfo.buildNumber})\n'
        'Device: ${deviceInfo.data}\n\n'
        '$diagnostics';
  }

  @override
  List<GrabKitPanel> buildPanels() => [
        GrabKitPanel(
          id: 'export.report',
          title: 'Export',
          icon: Icons.ios_share,
          builder: (_) => _ExportPanel(module: this),
        ),
      ];
}

class _ExportPanel extends StatelessWidget {
  const _ExportPanel({required this.module});

  final GrabKitExportModule module;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: () async => SharePlus.instance.share(
            ShareParams(
              text: await module.buildReport(),
              subject: 'GrabKit report',
            ),
          ),
          icon: const Icon(Icons.ios_share),
          label: const Text('Share debug report'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async => Clipboard.setData(
            ClipboardData(text: await module.buildReport()),
          ),
          icon: const Icon(Icons.copy),
          label: const Text('Copy debug report'),
        ),
      ],
    );
  }
}
