import 'package:eventix_scanner/core/qr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const token =
      '79078f2a3c3233cfc69552d97ec570b2eeff5dc0fdf83642c51c9cacc052fd57';

  test('an Eventix invitation QR gives its token and SHA-256', () {
    final code = parseScannedCode('https://eventix.om/qr/scan.php?t=$token');
    expect(code, isA<EventixCode>());
    code as EventixCode;
    expect(code.token, token);
    // the same hash the server sends as token_sha256 (PHP: hash('sha256', $token))
    expect(code.tokenSha256, tokenSha256(token));
    expect(code.tokenSha256, matches(RegExp(r'^[0-9a-f]{64}$')));
  });

  test('older and clean URLs, and extra parameters, still work', () {
    for (final raw in [
      'https://thermotechom.com/eventix/qr/scan.php?t=$token',
      'https://eventix.om/qr/scan?t=$token&from=web_scanner',
      '  https://eventix.om/qr/scan.php?t=$token\n',
    ]) {
      expect(parseScannedCode(raw), isA<EventixCode>(), reason: raw);
    }
  });

  test('a bare token is accepted, as the web scanner does', () {
    expect(parseScannedCode(token), isA<EventixCode>());
  });

  test('anything else is not an invitation', () {
    for (final raw in [
      'https://example.com/hello',
      'https://example.com/page?t=$token', // a t= on some other site
      'https://eventix.om/qr/scan.php', // no token
      'https://eventix.om/qr/scan.php?t=<script>',
      'WIFI:S:venue;T:WPA;P:secret;;',
      'hello world',
      '',
    ]) {
      expect(parseScannedCode(raw), isA<ForeignCode>(), reason: raw);
    }
  });

  test('the hash matches PHP hash("sha256") for a known value', () {
    // printf 'abc' | sha256sum
    expect(tokenSha256('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  });
}
