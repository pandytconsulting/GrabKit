import 'package:flutter/material.dart';

import '../core/runtime.dart';

/// Module-driven GrabKit dashboard.
class GrabKitShell extends StatefulWidget {
  const GrabKitShell({super.key, required this.runtime});

  final GrabKitRuntime runtime;

  @override
  State<GrabKitShell> createState() => _GrabKitShellState();
}

class _GrabKitShellState extends State<GrabKitShell> {
  @override
  void initState() {
    super.initState();
    widget.runtime.addListener(_refresh);
    widget.runtime.initialize();
  }

  @override
  void dispose() {
    widget.runtime.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final panels = widget.runtime.panels;
    if (!widget.runtime.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (panels.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('GrabKit')),
        body: const Center(child: Text('No GrabKit modules are enabled.')),
      );
    }
    return DefaultTabController(
      length: panels.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GrabKit'),
          bottom: TabBar(
            isScrollable: panels.length > 4,
            tabs: [
              for (final panel in panels)
                Tab(
                    icon: panel.icon == null ? null : Icon(panel.icon),
                    text: panel.title),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final panel in panels) Builder(builder: panel.builder)
          ],
        ),
      ),
    );
  }
}
