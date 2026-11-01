/// The JSON the Eventix scanner API sends and receives. Field names follow
/// the server (app/includes/scanner_api.php documents each request).
library;

class ApiUser {
  const ApiUser({required this.id, required this.username, required this.role});
  factory ApiUser.fromJson(Map<String, dynamic> j) => ApiUser(
        id: j['id'] as int,
        username: j['username'] as String,
        role: j['role'] as String,
      );
  final int id;
  final String username;
  final String role;
}

class LoginResult {
  const LoginResult(
      {required this.token, required this.expiresAt, required this.user});
  factory LoginResult.fromJson(Map<String, dynamic> j) => LoginResult(
        token: j['token'] as String,
        expiresAt: DateTime.parse(j['expires_at'] as String),
        user: ApiUser.fromJson(j['user'] as Map<String, dynamic>),
      );
  final String token;
  final DateTime expiresAt;
  final ApiUser user;
}

class ApiEvent {
  const ApiEvent({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.venueEn,
    required this.venueAr,
    required this.startsLabel,
    required this.timezone,
    required this.guestCount,
    required this.checkedInCount,
  });
  factory ApiEvent.fromJson(Map<String, dynamic> j) => ApiEvent(
        id: j['id'] as int,
        titleEn: j['title_en'] as String,
        titleAr: j['title_ar'] as String,
        venueEn: j['venue_en'] as String,
        venueAr: j['venue_ar'] as String,
        startsLabel: (j['starts_label'] as String?) ?? '',
        timezone: (j['timezone'] as String?) ?? 'Asia/Muscat',
        guestCount: j['guest_count'] as int,
        checkedInCount: j['checked_in_count'] as int,
      );
  final int id;
  final String titleEn;
  final String titleAr;
  final String venueEn;
  final String venueAr;
  final String startsLabel;
  final String timezone;
  final int guestCount;
  final int checkedInCount;
}

class ApiGuest {
  const ApiGuest({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.rsvp,
    required this.tableNumber,
    required this.tokenSha256,
    required this.checkedIn,
    required this.checkedInAt,
    required this.checkedInLabel,
  });
  factory ApiGuest.fromJson(Map<String, dynamic> j) => ApiGuest(
        id: j['id'] as int,
        nameEn: j['name_en'] as String,
        nameAr: j['name_ar'] as String,
        rsvp: j['rsvp'] as String,
        tableNumber: j['table_number'] as String?,
        tokenSha256: j['token_sha256'] as String,
        checkedIn: j['checked_in'] as bool,
        checkedInAt: j['checked_in_at'] == null
            ? null
            : DateTime.parse(j['checked_in_at'] as String),
        checkedInLabel: j['checked_in_label'] as String?,
      );
  final int id;
  final String nameEn;
  final String nameAr;
  final String rsvp;
  final String? tableNumber;
  final String tokenSha256;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final String? checkedInLabel;
}

class GuestList {
  const GuestList(
      {required this.event, required this.generatedAt, required this.guests});
  factory GuestList.fromJson(Map<String, dynamic> j) => GuestList(
        event: ApiEvent.fromJson(j['event'] as Map<String, dynamic>),
        generatedAt: DateTime.parse(j['generated_at'] as String),
        guests: (j['guests'] as List)
            .map((g) => ApiGuest.fromJson(g as Map<String, dynamic>))
            .toList(),
      );
  final ApiEvent event;
  final DateTime generatedAt;
  final List<ApiGuest> guests;
}

class CheckinUpload {
  const CheckinUpload(
      {required this.clientId, required this.guestId, required this.scannedAt});
  final String clientId;
  final int guestId;
  final DateTime scannedAt;
  Map<String, Object?> toJson() => {
        'client_id': clientId,
        'guest_id': guestId,
        'scanned_at': scannedAt.toUtc().toIso8601String(),
      };
}

/// The server's answer for one uploaded check-in.
class CheckinResult {
  const CheckinResult({
    required this.clientId,
    required this.status,
    this.checkedInAt,
    this.checkedInLabel,
    this.message,
    this.replayed = false,
  });
  factory CheckinResult.fromJson(Map<String, dynamic> j) => CheckinResult(
        clientId: j['client_id'] as String,
        status: j['status'] as String,
        checkedInAt: j['checked_in_at'] == null
            ? null
            : DateTime.parse(j['checked_in_at'] as String),
        checkedInLabel: j['checked_in_label'] as String?,
        message: j['message'] as String?,
        replayed: (j['replayed'] as bool?) ?? false,
      );

  /// checked_in · already_checked_in · not_found · forbidden · invalid
  final String status;
  final String clientId;
  final DateTime? checkedInAt;
  final String? checkedInLabel;
  final String? message;
  final bool replayed;
}
