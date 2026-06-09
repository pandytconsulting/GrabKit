import 'package:dio/dio.dart';
import 'package:grabkit_network/grabkit_network.dart';
import 'package:grabkit_network_dio/grabkit_network_dio.dart';
import 'package:test/test.dart';

void main() {
  test('captures and redacts a response', () async {
    final store = GrabKitNetworkStore();
    final dio = Dio()
      ..httpClientAdapter = _Adapter()
      ..interceptors.add(GrabKitDioInterceptor(store: store));
    await dio.get<void>(
      'https://example.com/test',
      queryParameters: {'access_token': 'secret'},
    );
    expect(store.entries.single.uri, contains('%5BREDACTED%5D'));
    expect(store.entries.single.responseSummary, '{}');
  });

  test('recording failures never interrupt a successful response', () async {
    final dio = Dio()
      ..httpClientAdapter = _Adapter()
      ..interceptors.add(
        GrabKitDioInterceptor(
          redactor: (_) => throw StateError('broken custom redactor'),
        ),
      );

    final response = await dio.get<String>('https://example.com/test');

    expect(response.statusCode, 200);
    expect(response.data, '{}');
  });
}

class _Adapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString('{}', 200);

  @override
  void close({bool force = false}) {}
}
