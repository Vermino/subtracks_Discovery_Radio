import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/log.dart';

void main() {
  group('Log Redaction', () {
    test('redacts Subsonic password parameter', () {
      const url = 'http://example.com/rest/ping.view?u=user&p=secretPassword&v=1.16.1&c=app';
      final redacted = redactUrl(url);
      expect(redacted, contains('p=REDACTED'));
      expect(redacted, isNot(contains('secretPassword')));
    });

    test('redacts Subsonic token parameter', () {
      const url = 'http://example.com/rest/ping.view?u=user&t=md5token&s=somesalt&v=1.16.1';
      final redacted = redactUrl(url);
      expect(redacted, contains('t=REDACTED'));
      expect(redacted, isNot(contains('md5token')));
    });

    test('redacts Subsonic salt parameter', () {
      const url = 'http://example.com/rest/ping.view?u=user&t=token&s=verySecretSalt&v=1.16.1';
      final redacted = redactUrl(url);
      expect(redacted, contains('s=REDACTED'));
      expect(redacted, isNot(contains('verySecretSalt')));
    });

    test('redacts username parameter', () {
      const url = 'http://example.com/rest/ping.view?u=mySensitiveUsername&p=pass';
      final redacted = redactUrl(url);
      expect(redacted, contains('u=REDACTED'));
      expect(redacted, isNot(contains('mySensitiveUsername')));
    });

    test('redacts multiple sensitive parameters', () {
      const url = 'http://example.com/rest/ping.view?u=user&p=pass&s=salt&t=token';
      final redacted = redactUrl(url);
      expect(redacted, contains('u=REDACTED'));
      expect(redacted, contains('p=REDACTED'));
      expect(redacted, contains('s=REDACTED'));
      expect(redacted, contains('t=REDACTED'));
      expect(redacted, isNot(contains('pass')));
      expect(redacted, isNot(contains('salt')));
      expect(redacted, isNot(contains('token')));
    });

    test('redacts parameters even if "u" is missing (security enhancement)', () {
      // This test confirms that we no longer rely on 'u' presence to redact 'p'
      const url = 'http://example.com/rest/ping.view?p=leakedPassword&v=1.16.1';
      final redacted = redactUrl(url);
      expect(redacted, contains('p=REDACTED'));
      expect(redacted, isNot(contains('leakedPassword')));
    });

    test('preserves non-sensitive parameters', () {
      const url = 'http://example.com/rest/ping.view?u=user&p=pass&v=1.16.1&c=subtracks';
      final redacted = redactUrl(url);
      expect(redacted, contains('v=1.16.1'));
      expect(redacted, contains('c=subtracks'));
    });

    test('handles empty string', () {
      expect(redactUrl(''), isEmpty);
    });

    test('handles no query parameters', () {
      const url = 'http://example.com/rest/ping.view';
      expect(redactUrl(url), equals(url));
    });

    test('handles parameters at end of string', () {
       const url = 'http://example.com?p=secret';
       final redacted = redactUrl(url);
       expect(redacted, contains('p=REDACTED'));
       expect(redacted, isNot(contains('secret')));
    });

    test('handles parameters followed by whitespace', () {
       const logMsg = 'Request: http://example.com?p=secret and then more text';
       final redacted = redactUrl(logMsg);
       expect(redacted, contains('p=REDACTED'));
       expect(redacted, isNot(contains('secret')));
       expect(redacted, contains(' and then more text'));
    });
  });
}
