import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config.dart';
import 'api_models.dart';

export 'api_models.dart';

/// Something went wrong talking to the server. The UI turns [code] into a
/// message in the app's language; [message] is the server's English text.
sealed class ApiException implements Exception {
  const ApiException(this.code, [this.message]);
  final String code;
  final String? message;
  @override
  String toString() => 'ApiException($code${message == null ? '' : ': $message'})';
}

/// No answer: no connection, DNS failure, timeout, TLS error.
class NetworkException extends ApiException {
  const NetworkException([String? message]) : super('network', message);
}

/// 401: the token is missing, expired or revoked. Sign in again.
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.code, [super.message]);
}

/// 429: too many requests (or sign-in attempts). Wait and retry.
class RateLimitedException extends ApiException {
  const RateLimitedException(super.code, [super.message]);
}

/// Any other refusal (400, 403, 404, 5xx…).
class ServerException extends ApiException {
  const ServerException(this.status, super.code, [super.message]);
  final int status;
}

/// The Eventix scanner API (app/api/scanner/*.php on the Eventix server).
class EventixApi {
  EventixApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _base = Uri.parse(baseUrl ?? AppConfig.baseUrl);

  final http.Client _client;
  final Uri _base;

  Future<LoginResult> login({
    required String username,
    required String password,
    required String deviceName,
  }) async {
    final body = await _send('POST', 'api/scanner/login.php', json: {
      'username': username,
      'password': password,
      'device_name': deviceName,
    });
    return LoginResult.fromJson(body);
  }

  /// Revokes the token. Errors are ignored: signing out works offline too.
  Future<void> logout(String token) async {
    try {
      await _send('POST', 'api/scanner/logout.php', token: token);
    } on ApiException {
      // the token expires on its own after 14 days
    }
  }

  Future<List<ApiEvent>> events(String token) async {
    final body = await _send('GET', 'api/scanner/events.php', token: token);
    return (body['events'] as List)
        .map((e) => ApiEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GuestList> guests(String token, int eventId) async {
    final body = await _send('GET', 'api/scanner/guests.php',
        token: token, query: {'event_id': '$eventId'});
    return GuestList.fromJson(body);
  }

  Future<List<CheckinResult>> uploadCheckins(
      String token, List<CheckinUpload> checkins) async {
    final body = await _send('POST', 'api/scanner/checkins.php',
        token: token,
        json: {'checkins': checkins.map((c) => c.toJson()).toList()});
    return (body['results'] as List)
        .map((r) => CheckinResult.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    String? token,
    Map<String, Object?>? json,
    Map<String, String>? query,
  }) async {
    final uri = _base.resolve(path).replace(queryParameters: query);
    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (json != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(json);
    }

    final http.Response response;
    try {
      final streamed =
          await _client.send(request).timeout(AppConfig.requestTimeout);
      response = await http.Response.fromStream(streamed)
          .timeout(AppConfig.requestTimeout);
    } on TimeoutException {
      throw const NetworkException('timeout');
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on HandshakeException catch (e) {
      throw NetworkException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }

    Map<String, dynamic>? decoded;
    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is Map<String, dynamic>) decoded = value;
    } on FormatException {
      decoded = null;
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300 && decoded != null) return decoded;

    final error = decoded?['error'];
    final code = error is Map ? '${error['code']}' : 'http_$status';
    final message = error is Map ? error['message'] as String? : null;
    if (status == 401) throw UnauthorizedException(code, message);
    if (status == 429) throw RateLimitedException(code, message);
    // a captive portal or proxy answering with its own HTML page: not our server
    if (decoded == null && status >= 200 && status < 400) {
      throw const NetworkException('unexpected response');
    }
    throw ServerException(status, code, message);
  }
}
