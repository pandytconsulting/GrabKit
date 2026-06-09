import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_network/grabkit_network.dart';

void main() {
  test('module declares network capture metadata', () {
    final metadata = GrabKitNetworkModule().metadata;

    expect(metadata.capturesEvents, isTrue);
    expect(metadata.contributesToReports, isTrue);
    expect(metadata.dataCategories, {GrabKitDataCategory.network});
  });

  test('stores newest records first', () {
    final store = GrabKitNetworkStore();
    final older = GrabKitNetworkRecord(
      at: DateTime(2026),
      method: 'GET',
      uri: 'https://example.com/old',
    );
    final newer = GrabKitNetworkRecord(
      at: DateTime(2026, 1, 2),
      method: 'POST',
      uri: 'https://example.com/new',
    );
    store
      ..add(older)
      ..add(newer);
    expect(store.entries, [newer, older]);
  });

  test('module connects records to the runtime event bus', () async {
    final store = GrabKitNetworkStore();
    final runtime =
        GrabKitRuntime(modules: [GrabKitNetworkModule(store: store)]);
    await runtime.initialize();

    store.add(
      GrabKitNetworkRecord(
        at: DateTime(2026),
        method: 'GET',
        uri: 'https://example.com',
      ),
    );

    expect(runtime.eventBus.entries.single.moduleId, 'network');
  });

  test('module disconnects the store when its runtime is disposed', () async {
    final store = GrabKitNetworkStore();
    final runtime =
        GrabKitRuntime(modules: [GrabKitNetworkModule(store: store)]);
    await runtime.initialize();

    runtime.dispose();
    store.add(
      GrabKitNetworkRecord(
        at: DateTime(2026),
        method: 'GET',
        uri: 'https://example.com/after-dispose',
      ),
    );

    expect(store.eventBus, isNull);
    expect(store.entries.single.uri, contains('after-dispose'));
  });

  test('network filter searches and filters captured calls', () {
    final success = GrabKitNetworkRecord(
      at: DateTime(2026),
      method: 'GET',
      uri: 'https://example.com/menu',
      statusCode: 200,
      responseSummary: '{"items":[]}',
    );
    final failure = GrabKitNetworkRecord(
      at: DateTime(2026),
      method: 'POST',
      uri: 'https://example.com/checkout',
      statusCode: 500,
    );

    expect(
      const GrabKitNetworkFilter(query: 'items').matches(success),
      isTrue,
    );
    expect(
      const GrabKitNetworkFilter(method: 'POST').matches(failure),
      isTrue,
    );
    expect(
      const GrabKitNetworkFilter(errorsOnly: true).matches(success),
      isFalse,
    );
  });

  test('cURL formatter includes redacted headers and request body', () {
    final record = GrabKitNetworkRecord(
      at: DateTime(2026),
      method: 'POST',
      uri: 'https://example.com/checkout',
      requestHeaders: const {'authorization': '[REDACTED]'},
      requestBody: const {'item': "Chef's special"},
    );

    final curl = GrabKitCurlFormatter.format(record);

    expect(curl, contains("curl -X 'POST'"));
    expect(curl, contains("'authorization: [REDACTED]'"));
    expect(curl, contains('--data-raw'));
    expect(curl, contains("Chef'\"'\"'s special"));
  });
}
