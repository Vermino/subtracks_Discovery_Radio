import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:subtracks/models/settings.dart';
import 'package:subtracks/sources/subsonic/client.dart';

void main() {
  group('SubsonicClient', () {
    test('uri generation with token auth', () {
      final settings = SubsonicSettings(
        id: 1,
        name: 'Test',
        address: Uri.parse('https://example.com'),
        isActive: true,
        createdAt: DateTime.now(),
        username: 'user',
        password: 'password',
        useTokenAuth: true,
      );

      final client = MockClient((request) async {
        return Response('', 200);
      });

      final subsonicClient = SubsonicClient(settings, client);

      final uri = subsonicClient.uri('ping');

      expect(uri.scheme, 'https');
      expect(uri.host, 'example.com');
      expect(uri.path, '/rest/ping.view');
      expect(uri.queryParameters['u'], 'user');
      expect(uri.queryParameters.containsKey('s'), isTrue); // Salt
      expect(uri.queryParameters.containsKey('t'), isTrue); // Token
      expect(uri.queryParameters.containsKey('p'), isFalse); // No plaintext password

      final salt = uri.queryParameters['s'];
      // Verify salt length (current impl generates 4 chars)
      expect(salt!.length, 4);
    });
  });
}
