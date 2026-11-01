import 'dart:convert';

import 'package:crypto/crypto.dart';

/// What a scanned code means at the door.
sealed class ScannedCode {
  const ScannedCode();
}

/// An Eventix invitation: its token, and the SHA-256 the guest list holds.
class EventixCode extends ScannedCode {
  const EventixCode(this.token, this.tokenSha256);
  final String token;
  final String tokenSha256;
}

/// Anything else: a web link, a payment code, a ticket from another system.
class ForeignCode extends ScannedCode {
  const ForeignCode(this.raw);
  final String raw;
}

final _bareToken = RegExp(r'^[A-Za-z0-9_-]{8,128}$');

/// Reads a scanned QR the way the Eventix web scanner does: an invitation QR
/// holds `https://<server>/qr/scan.php?t=<token>`; a bare token is accepted too.
/// Only the token's hash is ever compared, because the guest list on the phone
/// stores hashes, never tokens (a token is also the guest's RSVP link).
ScannedCode parseScannedCode(String raw) {
  final text = raw.trim();
  String? token;
  final uri = Uri.tryParse(text);
  if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
    if (uri.path.contains('/qr/scan')) token = uri.queryParameters['t'];
  } else if (_bareToken.hasMatch(text)) {
    token = text;
  }
  if (token == null || !_bareToken.hasMatch(token)) return ForeignCode(text);
  return EventixCode(token, tokenSha256(token));
}

String tokenSha256(String token) =>
    sha256.convert(utf8.encode(token)).toString();
