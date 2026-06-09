import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'curl_formatter.dart';
import 'network_filter.dart';
import 'network_record.dart';
import 'network_store.dart';

class GrabKitNetworkPanel extends StatefulWidget {
  const GrabKitNetworkPanel({super.key, required this.store});

  final GrabKitNetworkStore store;

  @override
  State<GrabKitNetworkPanel> createState() => _GrabKitNetworkPanelState();
}

class _GrabKitNetworkPanelState extends State<GrabKitNetworkPanel> {
  static const _allMethods = '__all__';

  final _searchController = TextEditingController();
  String? _method;
  bool _errorsOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final filter = GrabKitNetworkFilter(
          query: _searchController.text,
          method: _method,
          errorsOnly: _errorsOnly,
        );
        final entries =
            widget.store.entries.where(filter.matches).toList(growable: false);
        return Column(
          children: [
            _toolbar(context, entries.length),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        widget.store.entries.isEmpty
                            ? 'No network calls captured.'
                            : 'No network calls match the filters.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (_, index) =>
                          _NetworkCallTile(record: entries[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar(BuildContext context, int visibleCount) {
    final methods = widget.store.entries
        .map((entry) => entry.method.toUpperCase())
        .toSet()
        .toList()
      ..sort();
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search $visibleCount calls',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Filter method',
              icon: const Icon(Icons.filter_alt_outlined),
              onSelected: (value) => setState(
                () => _method = value == _allMethods ? null : value,
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _allMethods,
                  child: Text('All methods'),
                ),
                for (final method in methods)
                  PopupMenuItem(value: method, child: Text(method)),
              ],
            ),
            IconButton(
              tooltip: _errorsOnly ? 'Show all calls' : 'Show errors only',
              isSelected: _errorsOnly,
              onPressed: () => setState(() => _errorsOnly = !_errorsOnly),
              icon: const Icon(Icons.error_outline),
            ),
            IconButton(
              tooltip: 'Clear captured calls',
              onPressed: widget.store.entries.isEmpty
                  ? null
                  : () => _confirmClear(context),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear network calls?'),
        content: const Text('This removes all captured calls from GrabKit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (clear == true) widget.store.clear();
  }
}

class _NetworkCallTile extends StatelessWidget {
  const _NetworkCallTile({required this.record});

  final GrabKitNetworkRecord record;

  @override
  Widget build(BuildContext context) {
    final color = record.isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return ExpansionTile(
      leading: SizedBox(
        width: 52,
        child: Text(
          record.method.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(_shortUrl(record.uri), maxLines: 2),
      subtitle: Text(
        '${record.statusCode ?? '-'} · '
        '${record.duration?.inMilliseconds ?? '-'} ms',
      ),
      trailing: PopupMenuButton<_CallAction>(
        tooltip: 'Call actions',
        onSelected: (action) => _runAction(context, action),
        itemBuilder: (_) => const [
          PopupMenuItem(value: _CallAction.curl, child: Text('Copy cURL')),
          PopupMenuItem(
            value: _CallAction.url,
            child: Text('Copy URL'),
          ),
          PopupMenuItem(
            value: _CallAction.response,
            child: Text('Copy response'),
          ),
        ],
      ),
      children: [
        _Detail(label: 'URL', value: record.uri),
        if (record.requestSummary != null)
          _Detail(label: 'Request', value: record.requestSummary!),
        if (record.responseSummary != null)
          _Detail(label: 'Response', value: record.responseSummary!),
        if (record.errorMessage != null)
          _Detail(label: 'Error', value: record.errorMessage!),
      ],
    );
  }

  String _shortUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri == null ? value : '${uri.host}${uri.path}';
  }

  Future<void> _runAction(BuildContext context, _CallAction action) async {
    final text = switch (action) {
      _CallAction.curl => GrabKitCurlFormatter.format(record),
      _CallAction.url => record.uri,
      _CallAction.response => record.responseSummary ?? '',
    };
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No response body to copy.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${action.label} copied.')),
    );
  }
}

enum _CallAction {
  curl('cURL'),
  url('URL'),
  response('Response');

  const _CallAction(this.label);
  final String label;
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: SelectableText(value),
      trailing: IconButton(
        tooltip: 'Copy $label',
        onPressed: () => Clipboard.setData(ClipboardData(text: value)),
        icon: const Icon(Icons.copy),
      ),
    );
  }
}
