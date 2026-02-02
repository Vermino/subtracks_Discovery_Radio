import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:subtracks/models/settings.dart';
import 'package:subtracks/sources/subsonic/client.dart';

void main() {
  test('SubsonicClient generates 4-char salt for token auth', () {
    final settings = SubsonicSettings(
      id: 1,
      name: 'Test',
      address: Uri.parse('http://example.com'),
      isActive: true,
      createdAt: DateTime.now(),
      username: 'user',
      password: 'password',
      useTokenAuth: true,
    );

    final client = SubsonicClient(
      settings,
      MockClient((request) async => Response('ok', 200)),
    );

    final uri = client.uri('ping');
    final salt = uri.queryParameters['s'];

    expect(salt, isNotNull);
    expect(salt!.length, 4);
  });
}
