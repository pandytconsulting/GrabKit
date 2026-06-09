import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit_network/grabkit_network.dart';

void main() {
  testWidgets('inspector exposes details and cURL action', (tester) async {
    final store = GrabKitNetworkStore()
      ..add(
        GrabKitNetworkRecord(
          at: DateTime(2026),
          method: 'POST',
          uri: 'https://example.com/checkout',
          statusCode: 200,
          requestSummary: 'body: {"item":1}',
          responseSummary: '{"ok":true}',
        ),
      );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: Scaffold(body: GrabKitNetworkPanel(store: store)),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('example.com/checkout'), findsOneWidget);

    await tester.tap(find.text('example.com/checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Response'), findsOneWidget);

    await tester.tap(find.byTooltip('Call actions'));
    await tester.pumpAndSettle();
    expect(find.text('Copy cURL'), findsOneWidget);
    expect(find.text('Copy response'), findsOneWidget);
  });
}
