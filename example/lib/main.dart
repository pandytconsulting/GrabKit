import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';

void main() {
  runApp(const GrabKitExampleApp());
}

class GrabKitExampleApp extends StatefulWidget {
  const GrabKitExampleApp({super.key});

  @override
  State<GrabKitExampleApp> createState() => _GrabKitExampleAppState();
}

class _GrabKitExampleAppState extends State<GrabKitExampleApp> {
  late final GrabKitRuntime runtime = GrabKitRuntime(
    modules: [ExampleModule()],
  );

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: GrabKitShell(runtime: runtime),
    );
  }
}

class ExampleModule extends GrabKitModule {
  @override
  String get id => 'example';

  @override
  String get displayName => 'Example';

  @override
  Future<void> initialize(GrabKitRuntime runtime) async {
    runtime.eventBus.publish(
      GrabKitEvent(
        moduleId: id,
        type: 'ready',
        message: 'Example module initialized',
      ),
    );
  }

  @override
  List<GrabKitPanel> buildPanels() => const [
        GrabKitPanel(
          id: 'example.panel',
          title: 'Example',
          icon: Icons.extension,
          builder: _buildPanel,
        ),
      ];

  @override
  Future<void> dispose() async {}

  static Widget _buildPanel(BuildContext context) {
    return const Center(
        child: Text('A separately installable GrabKit module.'));
  }
}
