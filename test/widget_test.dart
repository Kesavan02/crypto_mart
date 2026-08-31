// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:crypto_mart/core/network/dio_client.dart';
import 'package:crypto_mart/features/crypto_market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_mart/features/crypto_market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_mart/features/crypto_market/data/repositories/crypto_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_mart/main.dart';

void main() {
  testWidgets('CryptoMartApp smoke test', (WidgetTester tester) async {
    final dioClient = DioClient();
    final remoteDataSource =
        CryptoRemoteDataSourceImpl(client: dioClient.instance);
    final localDataSource = CryptoLocalDataSourceImpl();
    final repository = CryptoRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    await tester.pumpWidget(CryptoMartApp(repository: repository));
    await tester.pump();

    expect(find.byType(CryptoMartApp), findsOneWidget);
  });
}
