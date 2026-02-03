import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:subtracks/models/settings.dart';
import 'package:subtracks/sources/subsonic/client.dart';

void main() {
  test('SubsonicClient generates valid URI with token auth', () {
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
    final mockHttp = MockClient((request) async {
      return Response('OK', 200);
    });

    final client = SubsonicClient(settings, mockHttp);

    final uri = client.uri('ping');

    expect(uri.queryParameters['u'], 'user');
    expect(uri.queryParameters.containsKey('s'), isTrue);
    expect(uri.queryParameters['s']!.length, 4);
    expect(uri.queryParameters.containsKey('t'), isTrue);
  });
}
