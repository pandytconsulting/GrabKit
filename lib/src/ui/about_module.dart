import 'package:flutter/material.dart';

import '../core/module.dart';
import '../core/runtime.dart';

/// Lightweight information panel that can be included in any GrabKit shell.
class GrabKitAboutModule extends GrabKitModule {
  @override
  String get id => 'about';

  @override
  String get displayName => 'About';

  @override
  GrabKitModuleMetadata get metadata =>
      const GrabKitModuleMetadata(hasSettings: false);

  @override
  Future<void> initialize(GrabKitRuntime runtime) async {}

  @override
  Future<void> dispose() async {}

  @override
  List<GrabKitPanel> buildPanels() => const [
        GrabKitPanel(
          id: 'about.info',
          title: 'About',
          icon: Icons.info_outline,
          builder: _buildAboutPanel,
        ),
      ];

  static Widget _buildAboutPanel(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Icon(Icons.bug_report_outlined, size: 48),
        SizedBox(height: 16),
        Text(
          'GrabKit',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'A modular in-app diagnostic toolkit for Flutter debug and QA builds.',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ListTile(
          leading: Icon(Icons.privacy_tip_outlined),
          title: Text('Review before sharing'),
          subtitle: Text(
            'GrabKit redacts common secrets, but applications should provide '
            'additional redaction for their own data.',
          ),
        ),
        ListTile(
          leading: Icon(Icons.shield_outlined),
          title: Text('Keep out of production'),
          subtitle: Text(
            'Expose GrabKit routes and capture adapters only in internal builds.',
          ),
        ),
      ],
    );
  }
}
