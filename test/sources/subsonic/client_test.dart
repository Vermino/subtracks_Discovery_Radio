import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:subtracks/models/settings.dart';
import 'package:subtracks/sources/subsonic/client.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class MockClient extends BaseClient {
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return StreamedResponse(Stream.empty(), 200);
  }
}

void main() {
  group('SubsonicClient', () {
    test('uri generation with token auth', () {
      final settings = SubsonicSettings(
        id: 1,
        name: 'Test',
        address: Uri.parse('http://example.com'),
        username: 'user',
        password: 'password',
        useTokenAuth: true,
        isActive: true,
        createdAt: DateTime.now(),
        features: IList(),
      );

      final client = SubsonicClient(settings, MockClient());

      final uri1 = client.uri('ping');
      final params1 = uri1.queryParameters;

      expect(params1['u'], 'user');
      expect(params1['p'], isNull); // Should not be present
      expect(params1['s'], isNotNull);
      expect(params1['t'], isNotNull);

      final salt1 = params1['s']!;
      expect(salt1.length, 16);
      final token1 = params1['t']!;
      final expectedToken1 = md5.convert(utf8.encode('password$salt1')).toString();
      expect(token1, expectedToken1);

      // Verify randomness (salt should change)
      final uri2 = client.uri('ping');
      final params2 = uri2.queryParameters;
      final salt2 = params2['s']!;
      expect(salt1, isNot(equals(salt2)));
    });

    test('uri generation without token auth', () {
      final settings = SubsonicSettings(
        id: 1,
        name: 'Test',
        address: Uri.parse('http://example.com'),
        username: 'user',
        password: 'password',
        useTokenAuth: false,
        isActive: true,
        createdAt: DateTime.now(),
        features: IList(),
      );

      final client = SubsonicClient(settings, MockClient());

      final uri = client.uri('ping');
      final params = uri.queryParameters;

      expect(params['u'], 'user');
      expect(params['p'], 'password'); // Should be present
      expect(params['s'], isNull);
      expect(params['t'], isNull);
    });
  });
}
