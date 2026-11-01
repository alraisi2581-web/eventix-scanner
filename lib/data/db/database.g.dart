// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleEnMeta = const VerificationMeta(
    'titleEn',
  );
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
    'title_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleArMeta = const VerificationMeta(
    'titleAr',
  );
  @override
  late final GeneratedColumn<String> titleAr = GeneratedColumn<String>(
    'title_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _venueEnMeta = const VerificationMeta(
    'venueEn',
  );
  @override
  late final GeneratedColumn<String> venueEn = GeneratedColumn<String>(
    'venue_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _venueArMeta = const VerificationMeta(
    'venueAr',
  );
  @override
  late final GeneratedColumn<String> venueAr = GeneratedColumn<String>(
    'venue_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsLabelMeta = const VerificationMeta(
    'startsLabel',
  );
  @override
  late final GeneratedColumn<String> startsLabel = GeneratedColumn<String>(
    'starts_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guestCountMeta = const VerificationMeta(
    'guestCount',
  );
  @override
  late final GeneratedColumn<int> guestCount = GeneratedColumn<int>(
    'guest_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedInCountMeta = const VerificationMeta(
    'checkedInCount',
  );
  @override
  late final GeneratedColumn<int> checkedInCount = GeneratedColumn<int>(
    'checked_in_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listDownloadedAtMeta = const VerificationMeta(
    'listDownloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> listDownloadedAt =
      GeneratedColumn<DateTime>(
        'list_downloaded_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    titleEn,
    titleAr,
    venueEn,
    venueAr,
    startsLabel,
    timezone,
    guestCount,
    checkedInCount,
    listDownloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(
        _titleEnMeta,
        titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta),
      );
    } else if (isInserting) {
      context.missing(_titleEnMeta);
    }
    if (data.containsKey('title_ar')) {
      context.handle(
        _titleArMeta,
        titleAr.isAcceptableOrUnknown(data['title_ar']!, _titleArMeta),
      );
    } else if (isInserting) {
      context.missing(_titleArMeta);
    }
    if (data.containsKey('venue_en')) {
      context.handle(
        _venueEnMeta,
        venueEn.isAcceptableOrUnknown(data['venue_en']!, _venueEnMeta),
      );
    } else if (isInserting) {
      context.missing(_venueEnMeta);
    }
    if (data.containsKey('venue_ar')) {
      context.handle(
        _venueArMeta,
        venueAr.isAcceptableOrUnknown(data['venue_ar']!, _venueArMeta),
      );
    } else if (isInserting) {
      context.missing(_venueArMeta);
    }
    if (data.containsKey('starts_label')) {
      context.handle(
        _startsLabelMeta,
        startsLabel.isAcceptableOrUnknown(
          data['starts_label']!,
          _startsLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startsLabelMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('guest_count')) {
      context.handle(
        _guestCountMeta,
        guestCount.isAcceptableOrUnknown(data['guest_count']!, _guestCountMeta),
      );
    } else if (isInserting) {
      context.missing(_guestCountMeta);
    }
    if (data.containsKey('checked_in_count')) {
      context.handle(
        _checkedInCountMeta,
        checkedInCount.isAcceptableOrUnknown(
          data['checked_in_count']!,
          _checkedInCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkedInCountMeta);
    }
    if (data.containsKey('list_downloaded_at')) {
      context.handle(
        _listDownloadedAtMeta,
        listDownloadedAt.isAcceptableOrUnknown(
          data['list_downloaded_at']!,
          _listDownloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      titleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_en'],
      )!,
      titleAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_ar'],
      )!,
      venueEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venue_en'],
      )!,
      venueAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venue_ar'],
      )!,
      startsLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts_label'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      guestCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guest_count'],
      )!,
      checkedInCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checked_in_count'],
      )!,
      listDownloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}list_downloaded_at'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final int id;
  final int userId;
  final String titleEn;
  final String titleAr;
  final String venueEn;
  final String venueAr;
  final String startsLabel;
  final String timezone;
  final int guestCount;
  final int checkedInCount;

  /// When this event's guest list was last saved on the phone; null = never.
  final DateTime? listDownloadedAt;
  const EventRow({
    required this.id,
    required this.userId,
    required this.titleEn,
    required this.titleAr,
    required this.venueEn,
    required this.venueAr,
    required this.startsLabel,
    required this.timezone,
    required this.guestCount,
    required this.checkedInCount,
    this.listDownloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['title_en'] = Variable<String>(titleEn);
    map['title_ar'] = Variable<String>(titleAr);
    map['venue_en'] = Variable<String>(venueEn);
    map['venue_ar'] = Variable<String>(venueAr);
    map['starts_label'] = Variable<String>(startsLabel);
    map['timezone'] = Variable<String>(timezone);
    map['guest_count'] = Variable<int>(guestCount);
    map['checked_in_count'] = Variable<int>(checkedInCount);
    if (!nullToAbsent || listDownloadedAt != null) {
      map['list_downloaded_at'] = Variable<DateTime>(listDownloadedAt);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      userId: Value(userId),
      titleEn: Value(titleEn),
      titleAr: Value(titleAr),
      venueEn: Value(venueEn),
      venueAr: Value(venueAr),
      startsLabel: Value(startsLabel),
      timezone: Value(timezone),
      guestCount: Value(guestCount),
      checkedInCount: Value(checkedInCount),
      listDownloadedAt: listDownloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(listDownloadedAt),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      titleEn: serializer.fromJson<String>(json['titleEn']),
      titleAr: serializer.fromJson<String>(json['titleAr']),
      venueEn: serializer.fromJson<String>(json['venueEn']),
      venueAr: serializer.fromJson<String>(json['venueAr']),
      startsLabel: serializer.fromJson<String>(json['startsLabel']),
      timezone: serializer.fromJson<String>(json['timezone']),
      guestCount: serializer.fromJson<int>(json['guestCount']),
      checkedInCount: serializer.fromJson<int>(json['checkedInCount']),
      listDownloadedAt: serializer.fromJson<DateTime?>(
        json['listDownloadedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'titleEn': serializer.toJson<String>(titleEn),
      'titleAr': serializer.toJson<String>(titleAr),
      'venueEn': serializer.toJson<String>(venueEn),
      'venueAr': serializer.toJson<String>(venueAr),
      'startsLabel': serializer.toJson<String>(startsLabel),
      'timezone': serializer.toJson<String>(timezone),
      'guestCount': serializer.toJson<int>(guestCount),
      'checkedInCount': serializer.toJson<int>(checkedInCount),
      'listDownloadedAt': serializer.toJson<DateTime?>(listDownloadedAt),
    };
  }

  EventRow copyWith({
    int? id,
    int? userId,
    String? titleEn,
    String? titleAr,
    String? venueEn,
    String? venueAr,
    String? startsLabel,
    String? timezone,
    int? guestCount,
    int? checkedInCount,
    Value<DateTime?> listDownloadedAt = const Value.absent(),
  }) => EventRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    titleEn: titleEn ?? this.titleEn,
    titleAr: titleAr ?? this.titleAr,
    venueEn: venueEn ?? this.venueEn,
    venueAr: venueAr ?? this.venueAr,
    startsLabel: startsLabel ?? this.startsLabel,
    timezone: timezone ?? this.timezone,
    guestCount: guestCount ?? this.guestCount,
    checkedInCount: checkedInCount ?? this.checkedInCount,
    listDownloadedAt: listDownloadedAt.present
        ? listDownloadedAt.value
        : this.listDownloadedAt,
  );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      titleAr: data.titleAr.present ? data.titleAr.value : this.titleAr,
      venueEn: data.venueEn.present ? data.venueEn.value : this.venueEn,
      venueAr: data.venueAr.present ? data.venueAr.value : this.venueAr,
      startsLabel: data.startsLabel.present
          ? data.startsLabel.value
          : this.startsLabel,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      guestCount: data.guestCount.present
          ? data.guestCount.value
          : this.guestCount,
      checkedInCount: data.checkedInCount.present
          ? data.checkedInCount.value
          : this.checkedInCount,
      listDownloadedAt: data.listDownloadedAt.present
          ? data.listDownloadedAt.value
          : this.listDownloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleAr: $titleAr, ')
          ..write('venueEn: $venueEn, ')
          ..write('venueAr: $venueAr, ')
          ..write('startsLabel: $startsLabel, ')
          ..write('timezone: $timezone, ')
          ..write('guestCount: $guestCount, ')
          ..write('checkedInCount: $checkedInCount, ')
          ..write('listDownloadedAt: $listDownloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    titleEn,
    titleAr,
    venueEn,
    venueAr,
    startsLabel,
    timezone,
    guestCount,
    checkedInCount,
    listDownloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.titleEn == this.titleEn &&
          other.titleAr == this.titleAr &&
          other.venueEn == this.venueEn &&
          other.venueAr == this.venueAr &&
          other.startsLabel == this.startsLabel &&
          other.timezone == this.timezone &&
          other.guestCount == this.guestCount &&
          other.checkedInCount == this.checkedInCount &&
          other.listDownloadedAt == this.listDownloadedAt);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> titleEn;
  final Value<String> titleAr;
  final Value<String> venueEn;
  final Value<String> venueAr;
  final Value<String> startsLabel;
  final Value<String> timezone;
  final Value<int> guestCount;
  final Value<int> checkedInCount;
  final Value<DateTime?> listDownloadedAt;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.titleAr = const Value.absent(),
    this.venueEn = const Value.absent(),
    this.venueAr = const Value.absent(),
    this.startsLabel = const Value.absent(),
    this.timezone = const Value.absent(),
    this.guestCount = const Value.absent(),
    this.checkedInCount = const Value.absent(),
    this.listDownloadedAt = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String titleEn,
    required String titleAr,
    required String venueEn,
    required String venueAr,
    required String startsLabel,
    required String timezone,
    required int guestCount,
    required int checkedInCount,
    this.listDownloadedAt = const Value.absent(),
  }) : userId = Value(userId),
       titleEn = Value(titleEn),
       titleAr = Value(titleAr),
       venueEn = Value(venueEn),
       venueAr = Value(venueAr),
       startsLabel = Value(startsLabel),
       timezone = Value(timezone),
       guestCount = Value(guestCount),
       checkedInCount = Value(checkedInCount);
  static Insertable<EventRow> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? titleEn,
    Expression<String>? titleAr,
    Expression<String>? venueEn,
    Expression<String>? venueAr,
    Expression<String>? startsLabel,
    Expression<String>? timezone,
    Expression<int>? guestCount,
    Expression<int>? checkedInCount,
    Expression<DateTime>? listDownloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (titleEn != null) 'title_en': titleEn,
      if (titleAr != null) 'title_ar': titleAr,
      if (venueEn != null) 'venue_en': venueEn,
      if (venueAr != null) 'venue_ar': venueAr,
      if (startsLabel != null) 'starts_label': startsLabel,
      if (timezone != null) 'timezone': timezone,
      if (guestCount != null) 'guest_count': guestCount,
      if (checkedInCount != null) 'checked_in_count': checkedInCount,
      if (listDownloadedAt != null) 'list_downloaded_at': listDownloadedAt,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? titleEn,
    Value<String>? titleAr,
    Value<String>? venueEn,
    Value<String>? venueAr,
    Value<String>? startsLabel,
    Value<String>? timezone,
    Value<int>? guestCount,
    Value<int>? checkedInCount,
    Value<DateTime?>? listDownloadedAt,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      venueEn: venueEn ?? this.venueEn,
      venueAr: venueAr ?? this.venueAr,
      startsLabel: startsLabel ?? this.startsLabel,
      timezone: timezone ?? this.timezone,
      guestCount: guestCount ?? this.guestCount,
      checkedInCount: checkedInCount ?? this.checkedInCount,
      listDownloadedAt: listDownloadedAt ?? this.listDownloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (titleAr.present) {
      map['title_ar'] = Variable<String>(titleAr.value);
    }
    if (venueEn.present) {
      map['venue_en'] = Variable<String>(venueEn.value);
    }
    if (venueAr.present) {
      map['venue_ar'] = Variable<String>(venueAr.value);
    }
    if (startsLabel.present) {
      map['starts_label'] = Variable<String>(startsLabel.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (guestCount.present) {
      map['guest_count'] = Variable<int>(guestCount.value);
    }
    if (checkedInCount.present) {
      map['checked_in_count'] = Variable<int>(checkedInCount.value);
    }
    if (listDownloadedAt.present) {
      map['list_downloaded_at'] = Variable<DateTime>(listDownloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleAr: $titleAr, ')
          ..write('venueEn: $venueEn, ')
          ..write('venueAr: $venueAr, ')
          ..write('startsLabel: $startsLabel, ')
          ..write('timezone: $timezone, ')
          ..write('guestCount: $guestCount, ')
          ..write('checkedInCount: $checkedInCount, ')
          ..write('listDownloadedAt: $listDownloadedAt')
          ..write(')'))
        .toString();
  }
}

class $GuestsTable extends Guests with TableInfo<$GuestsTable, GuestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rsvpMeta = const VerificationMeta('rsvp');
  @override
  late final GeneratedColumn<String> rsvp = GeneratedColumn<String>(
    'rsvp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableNumberMeta = const VerificationMeta(
    'tableNumber',
  );
  @override
  late final GeneratedColumn<String> tableNumber = GeneratedColumn<String>(
    'table_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenSha256Meta = const VerificationMeta(
    'tokenSha256',
  );
  @override
  late final GeneratedColumn<String> tokenSha256 = GeneratedColumn<String>(
    'token_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverCheckedInMeta = const VerificationMeta(
    'serverCheckedIn',
  );
  @override
  late final GeneratedColumn<bool> serverCheckedIn = GeneratedColumn<bool>(
    'server_checked_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("server_checked_in" IN (0, 1))',
    ),
  );
  static const VerificationMeta _serverCheckedInLabelMeta =
      const VerificationMeta('serverCheckedInLabel');
  @override
  late final GeneratedColumn<String> serverCheckedInLabel =
      GeneratedColumn<String>(
        'server_checked_in_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    nameEn,
    nameAr,
    rsvp,
    tableNumber,
    tokenSha256,
    serverCheckedIn,
    serverCheckedInLabel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guests';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('rsvp')) {
      context.handle(
        _rsvpMeta,
        rsvp.isAcceptableOrUnknown(data['rsvp']!, _rsvpMeta),
      );
    } else if (isInserting) {
      context.missing(_rsvpMeta);
    }
    if (data.containsKey('table_number')) {
      context.handle(
        _tableNumberMeta,
        tableNumber.isAcceptableOrUnknown(
          data['table_number']!,
          _tableNumberMeta,
        ),
      );
    }
    if (data.containsKey('token_sha256')) {
      context.handle(
        _tokenSha256Meta,
        tokenSha256.isAcceptableOrUnknown(
          data['token_sha256']!,
          _tokenSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tokenSha256Meta);
    }
    if (data.containsKey('server_checked_in')) {
      context.handle(
        _serverCheckedInMeta,
        serverCheckedIn.isAcceptableOrUnknown(
          data['server_checked_in']!,
          _serverCheckedInMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverCheckedInMeta);
    }
    if (data.containsKey('server_checked_in_label')) {
      context.handle(
        _serverCheckedInLabelMeta,
        serverCheckedInLabel.isAcceptableOrUnknown(
          data['server_checked_in_label']!,
          _serverCheckedInLabelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GuestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
      rsvp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rsvp'],
      )!,
      tableNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_number'],
      ),
      tokenSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_sha256'],
      )!,
      serverCheckedIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}server_checked_in'],
      )!,
      serverCheckedInLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_checked_in_label'],
      ),
    );
  }

  @override
  $GuestsTable createAlias(String alias) {
    return $GuestsTable(attachedDatabase, alias);
  }
}

class GuestRow extends DataClass implements Insertable<GuestRow> {
  final int id;
  final int eventId;
  final String nameEn;
  final String nameAr;
  final String rsvp;
  final String? tableNumber;
  final String tokenSha256;

  /// Checked in on the server as of the last download (by anyone).
  final bool serverCheckedIn;
  final String? serverCheckedInLabel;
  const GuestRow({
    required this.id,
    required this.eventId,
    required this.nameEn,
    required this.nameAr,
    required this.rsvp,
    this.tableNumber,
    required this.tokenSha256,
    required this.serverCheckedIn,
    this.serverCheckedInLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<int>(eventId);
    map['name_en'] = Variable<String>(nameEn);
    map['name_ar'] = Variable<String>(nameAr);
    map['rsvp'] = Variable<String>(rsvp);
    if (!nullToAbsent || tableNumber != null) {
      map['table_number'] = Variable<String>(tableNumber);
    }
    map['token_sha256'] = Variable<String>(tokenSha256);
    map['server_checked_in'] = Variable<bool>(serverCheckedIn);
    if (!nullToAbsent || serverCheckedInLabel != null) {
      map['server_checked_in_label'] = Variable<String>(serverCheckedInLabel);
    }
    return map;
  }

  GuestsCompanion toCompanion(bool nullToAbsent) {
    return GuestsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      nameEn: Value(nameEn),
      nameAr: Value(nameAr),
      rsvp: Value(rsvp),
      tableNumber: tableNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(tableNumber),
      tokenSha256: Value(tokenSha256),
      serverCheckedIn: Value(serverCheckedIn),
      serverCheckedInLabel: serverCheckedInLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(serverCheckedInLabel),
    );
  }

  factory GuestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuestRow(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int>(json['eventId']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      rsvp: serializer.fromJson<String>(json['rsvp']),
      tableNumber: serializer.fromJson<String?>(json['tableNumber']),
      tokenSha256: serializer.fromJson<String>(json['tokenSha256']),
      serverCheckedIn: serializer.fromJson<bool>(json['serverCheckedIn']),
      serverCheckedInLabel: serializer.fromJson<String?>(
        json['serverCheckedInLabel'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int>(eventId),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameAr': serializer.toJson<String>(nameAr),
      'rsvp': serializer.toJson<String>(rsvp),
      'tableNumber': serializer.toJson<String?>(tableNumber),
      'tokenSha256': serializer.toJson<String>(tokenSha256),
      'serverCheckedIn': serializer.toJson<bool>(serverCheckedIn),
      'serverCheckedInLabel': serializer.toJson<String?>(serverCheckedInLabel),
    };
  }

  GuestRow copyWith({
    int? id,
    int? eventId,
    String? nameEn,
    String? nameAr,
    String? rsvp,
    Value<String?> tableNumber = const Value.absent(),
    String? tokenSha256,
    bool? serverCheckedIn,
    Value<String?> serverCheckedInLabel = const Value.absent(),
  }) => GuestRow(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    nameEn: nameEn ?? this.nameEn,
    nameAr: nameAr ?? this.nameAr,
    rsvp: rsvp ?? this.rsvp,
    tableNumber: tableNumber.present ? tableNumber.value : this.tableNumber,
    tokenSha256: tokenSha256 ?? this.tokenSha256,
    serverCheckedIn: serverCheckedIn ?? this.serverCheckedIn,
    serverCheckedInLabel: serverCheckedInLabel.present
        ? serverCheckedInLabel.value
        : this.serverCheckedInLabel,
  );
  GuestRow copyWithCompanion(GuestsCompanion data) {
    return GuestRow(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      rsvp: data.rsvp.present ? data.rsvp.value : this.rsvp,
      tableNumber: data.tableNumber.present
          ? data.tableNumber.value
          : this.tableNumber,
      tokenSha256: data.tokenSha256.present
          ? data.tokenSha256.value
          : this.tokenSha256,
      serverCheckedIn: data.serverCheckedIn.present
          ? data.serverCheckedIn.value
          : this.serverCheckedIn,
      serverCheckedInLabel: data.serverCheckedInLabel.present
          ? data.serverCheckedInLabel.value
          : this.serverCheckedInLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuestRow(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameAr: $nameAr, ')
          ..write('rsvp: $rsvp, ')
          ..write('tableNumber: $tableNumber, ')
          ..write('tokenSha256: $tokenSha256, ')
          ..write('serverCheckedIn: $serverCheckedIn, ')
          ..write('serverCheckedInLabel: $serverCheckedInLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    nameEn,
    nameAr,
    rsvp,
    tableNumber,
    tokenSha256,
    serverCheckedIn,
    serverCheckedInLabel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuestRow &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.nameEn == this.nameEn &&
          other.nameAr == this.nameAr &&
          other.rsvp == this.rsvp &&
          other.tableNumber == this.tableNumber &&
          other.tokenSha256 == this.tokenSha256 &&
          other.serverCheckedIn == this.serverCheckedIn &&
          other.serverCheckedInLabel == this.serverCheckedInLabel);
}

class GuestsCompanion extends UpdateCompanion<GuestRow> {
  final Value<int> id;
  final Value<int> eventId;
  final Value<String> nameEn;
  final Value<String> nameAr;
  final Value<String> rsvp;
  final Value<String?> tableNumber;
  final Value<String> tokenSha256;
  final Value<bool> serverCheckedIn;
  final Value<String?> serverCheckedInLabel;
  const GuestsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.rsvp = const Value.absent(),
    this.tableNumber = const Value.absent(),
    this.tokenSha256 = const Value.absent(),
    this.serverCheckedIn = const Value.absent(),
    this.serverCheckedInLabel = const Value.absent(),
  });
  GuestsCompanion.insert({
    this.id = const Value.absent(),
    required int eventId,
    required String nameEn,
    required String nameAr,
    required String rsvp,
    this.tableNumber = const Value.absent(),
    required String tokenSha256,
    required bool serverCheckedIn,
    this.serverCheckedInLabel = const Value.absent(),
  }) : eventId = Value(eventId),
       nameEn = Value(nameEn),
       nameAr = Value(nameAr),
       rsvp = Value(rsvp),
       tokenSha256 = Value(tokenSha256),
       serverCheckedIn = Value(serverCheckedIn);
  static Insertable<GuestRow> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<String>? nameEn,
    Expression<String>? nameAr,
    Expression<String>? rsvp,
    Expression<String>? tableNumber,
    Expression<String>? tokenSha256,
    Expression<bool>? serverCheckedIn,
    Expression<String>? serverCheckedInLabel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (nameEn != null) 'name_en': nameEn,
      if (nameAr != null) 'name_ar': nameAr,
      if (rsvp != null) 'rsvp': rsvp,
      if (tableNumber != null) 'table_number': tableNumber,
      if (tokenSha256 != null) 'token_sha256': tokenSha256,
      if (serverCheckedIn != null) 'server_checked_in': serverCheckedIn,
      if (serverCheckedInLabel != null)
        'server_checked_in_label': serverCheckedInLabel,
    });
  }

  GuestsCompanion copyWith({
    Value<int>? id,
    Value<int>? eventId,
    Value<String>? nameEn,
    Value<String>? nameAr,
    Value<String>? rsvp,
    Value<String?>? tableNumber,
    Value<String>? tokenSha256,
    Value<bool>? serverCheckedIn,
    Value<String?>? serverCheckedInLabel,
  }) {
    return GuestsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      rsvp: rsvp ?? this.rsvp,
      tableNumber: tableNumber ?? this.tableNumber,
      tokenSha256: tokenSha256 ?? this.tokenSha256,
      serverCheckedIn: serverCheckedIn ?? this.serverCheckedIn,
      serverCheckedInLabel: serverCheckedInLabel ?? this.serverCheckedInLabel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (rsvp.present) {
      map['rsvp'] = Variable<String>(rsvp.value);
    }
    if (tableNumber.present) {
      map['table_number'] = Variable<String>(tableNumber.value);
    }
    if (tokenSha256.present) {
      map['token_sha256'] = Variable<String>(tokenSha256.value);
    }
    if (serverCheckedIn.present) {
      map['server_checked_in'] = Variable<bool>(serverCheckedIn.value);
    }
    if (serverCheckedInLabel.present) {
      map['server_checked_in_label'] = Variable<String>(
        serverCheckedInLabel.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuestsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameAr: $nameAr, ')
          ..write('rsvp: $rsvp, ')
          ..write('tableNumber: $tableNumber, ')
          ..write('tokenSha256: $tokenSha256, ')
          ..write('serverCheckedIn: $serverCheckedIn, ')
          ..write('serverCheckedInLabel: $serverCheckedInLabel')
          ..write(')'))
        .toString();
  }
}

class $CheckinsTable extends Checkins
    with TableInfo<$CheckinsTable, CheckinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<int> guestId = GeneratedColumn<int>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guestNameEnMeta = const VerificationMeta(
    'guestNameEn',
  );
  @override
  late final GeneratedColumn<String> guestNameEn = GeneratedColumn<String>(
    'guest_name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guestNameArMeta = const VerificationMeta(
    'guestNameAr',
  );
  @override
  late final GeneratedColumn<String> guestNameAr = GeneratedColumn<String>(
    'guest_name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CheckinState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CheckinState>($CheckinsTable.$converterstate);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverLabelMeta = const VerificationMeta(
    'serverLabel',
  );
  @override
  late final GeneratedColumn<String> serverLabel = GeneratedColumn<String>(
    'server_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    userId,
    username,
    eventId,
    guestId,
    guestNameEn,
    guestNameAr,
    scannedAt,
    state,
    attempts,
    syncedAt,
    serverLabel,
    message,
    seen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckinRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('guest_name_en')) {
      context.handle(
        _guestNameEnMeta,
        guestNameEn.isAcceptableOrUnknown(
          data['guest_name_en']!,
          _guestNameEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guestNameEnMeta);
    }
    if (data.containsKey('guest_name_ar')) {
      context.handle(
        _guestNameArMeta,
        guestNameAr.isAcceptableOrUnknown(
          data['guest_name_ar']!,
          _guestNameArMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guestNameArMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('server_label')) {
      context.handle(
        _serverLabelMeta,
        serverLabel.isAcceptableOrUnknown(
          data['server_label']!,
          _serverLabelMeta,
        ),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventId, guestId},
  ];
  @override
  CheckinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckinRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guest_id'],
      )!,
      guestNameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_name_en'],
      )!,
      guestNameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_name_ar'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
      state: $CheckinsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      serverLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_label'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
    );
  }

  @override
  $CheckinsTable createAlias(String alias) {
    return $CheckinsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CheckinState, String, String> $converterstate =
      const EnumNameConverter<CheckinState>(CheckinState.values);
}

class CheckinRow extends DataClass implements Insertable<CheckinRow> {
  /// UUID v4 made on the phone; the server's idempotency key.
  final String clientId;
  final int userId;
  final String username;
  final int eventId;
  final int guestId;
  final String guestNameEn;
  final String guestNameAr;
  final DateTime scannedAt;
  final CheckinState state;
  final int attempts;
  final DateTime? syncedAt;

  /// The check-in time the server recorded, in the event's zone ("7:42 pm").
  final String? serverLabel;
  final String? message;

  /// False until door staff have seen a conflict or refusal.
  final bool seen;
  const CheckinRow({
    required this.clientId,
    required this.userId,
    required this.username,
    required this.eventId,
    required this.guestId,
    required this.guestNameEn,
    required this.guestNameAr,
    required this.scannedAt,
    required this.state,
    required this.attempts,
    this.syncedAt,
    this.serverLabel,
    this.message,
    required this.seen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['user_id'] = Variable<int>(userId);
    map['username'] = Variable<String>(username);
    map['event_id'] = Variable<int>(eventId);
    map['guest_id'] = Variable<int>(guestId);
    map['guest_name_en'] = Variable<String>(guestNameEn);
    map['guest_name_ar'] = Variable<String>(guestNameAr);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    {
      map['state'] = Variable<String>(
        $CheckinsTable.$converterstate.toSql(state),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || serverLabel != null) {
      map['server_label'] = Variable<String>(serverLabel);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['seen'] = Variable<bool>(seen);
    return map;
  }

  CheckinsCompanion toCompanion(bool nullToAbsent) {
    return CheckinsCompanion(
      clientId: Value(clientId),
      userId: Value(userId),
      username: Value(username),
      eventId: Value(eventId),
      guestId: Value(guestId),
      guestNameEn: Value(guestNameEn),
      guestNameAr: Value(guestNameAr),
      scannedAt: Value(scannedAt),
      state: Value(state),
      attempts: Value(attempts),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      serverLabel: serverLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(serverLabel),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      seen: Value(seen),
    );
  }

  factory CheckinRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckinRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      userId: serializer.fromJson<int>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      eventId: serializer.fromJson<int>(json['eventId']),
      guestId: serializer.fromJson<int>(json['guestId']),
      guestNameEn: serializer.fromJson<String>(json['guestNameEn']),
      guestNameAr: serializer.fromJson<String>(json['guestNameAr']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
      state: $CheckinsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      serverLabel: serializer.fromJson<String?>(json['serverLabel']),
      message: serializer.fromJson<String?>(json['message']),
      seen: serializer.fromJson<bool>(json['seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'userId': serializer.toJson<int>(userId),
      'username': serializer.toJson<String>(username),
      'eventId': serializer.toJson<int>(eventId),
      'guestId': serializer.toJson<int>(guestId),
      'guestNameEn': serializer.toJson<String>(guestNameEn),
      'guestNameAr': serializer.toJson<String>(guestNameAr),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
      'state': serializer.toJson<String>(
        $CheckinsTable.$converterstate.toJson(state),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'serverLabel': serializer.toJson<String?>(serverLabel),
      'message': serializer.toJson<String?>(message),
      'seen': serializer.toJson<bool>(seen),
    };
  }

  CheckinRow copyWith({
    String? clientId,
    int? userId,
    String? username,
    int? eventId,
    int? guestId,
    String? guestNameEn,
    String? guestNameAr,
    DateTime? scannedAt,
    CheckinState? state,
    int? attempts,
    Value<DateTime?> syncedAt = const Value.absent(),
    Value<String?> serverLabel = const Value.absent(),
    Value<String?> message = const Value.absent(),
    bool? seen,
  }) => CheckinRow(
    clientId: clientId ?? this.clientId,
    userId: userId ?? this.userId,
    username: username ?? this.username,
    eventId: eventId ?? this.eventId,
    guestId: guestId ?? this.guestId,
    guestNameEn: guestNameEn ?? this.guestNameEn,
    guestNameAr: guestNameAr ?? this.guestNameAr,
    scannedAt: scannedAt ?? this.scannedAt,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    serverLabel: serverLabel.present ? serverLabel.value : this.serverLabel,
    message: message.present ? message.value : this.message,
    seen: seen ?? this.seen,
  );
  CheckinRow copyWithCompanion(CheckinsCompanion data) {
    return CheckinRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      guestNameEn: data.guestNameEn.present
          ? data.guestNameEn.value
          : this.guestNameEn,
      guestNameAr: data.guestNameAr.present
          ? data.guestNameAr.value
          : this.guestNameAr,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      serverLabel: data.serverLabel.present
          ? data.serverLabel.value
          : this.serverLabel,
      message: data.message.present ? data.message.value : this.message,
      seen: data.seen.present ? data.seen.value : this.seen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckinRow(')
          ..write('clientId: $clientId, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('eventId: $eventId, ')
          ..write('guestId: $guestId, ')
          ..write('guestNameEn: $guestNameEn, ')
          ..write('guestNameAr: $guestNameAr, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverLabel: $serverLabel, ')
          ..write('message: $message, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    userId,
    username,
    eventId,
    guestId,
    guestNameEn,
    guestNameAr,
    scannedAt,
    state,
    attempts,
    syncedAt,
    serverLabel,
    message,
    seen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckinRow &&
          other.clientId == this.clientId &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.eventId == this.eventId &&
          other.guestId == this.guestId &&
          other.guestNameEn == this.guestNameEn &&
          other.guestNameAr == this.guestNameAr &&
          other.scannedAt == this.scannedAt &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.syncedAt == this.syncedAt &&
          other.serverLabel == this.serverLabel &&
          other.message == this.message &&
          other.seen == this.seen);
}

class CheckinsCompanion extends UpdateCompanion<CheckinRow> {
  final Value<String> clientId;
  final Value<int> userId;
  final Value<String> username;
  final Value<int> eventId;
  final Value<int> guestId;
  final Value<String> guestNameEn;
  final Value<String> guestNameAr;
  final Value<DateTime> scannedAt;
  final Value<CheckinState> state;
  final Value<int> attempts;
  final Value<DateTime?> syncedAt;
  final Value<String?> serverLabel;
  final Value<String?> message;
  final Value<bool> seen;
  final Value<int> rowid;
  const CheckinsCompanion({
    this.clientId = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.eventId = const Value.absent(),
    this.guestId = const Value.absent(),
    this.guestNameEn = const Value.absent(),
    this.guestNameAr = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverLabel = const Value.absent(),
    this.message = const Value.absent(),
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckinsCompanion.insert({
    required String clientId,
    required int userId,
    required String username,
    required int eventId,
    required int guestId,
    required String guestNameEn,
    required String guestNameAr,
    required DateTime scannedAt,
    required CheckinState state,
    this.attempts = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverLabel = const Value.absent(),
    this.message = const Value.absent(),
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       userId = Value(userId),
       username = Value(username),
       eventId = Value(eventId),
       guestId = Value(guestId),
       guestNameEn = Value(guestNameEn),
       guestNameAr = Value(guestNameAr),
       scannedAt = Value(scannedAt),
       state = Value(state);
  static Insertable<CheckinRow> custom({
    Expression<String>? clientId,
    Expression<int>? userId,
    Expression<String>? username,
    Expression<int>? eventId,
    Expression<int>? guestId,
    Expression<String>? guestNameEn,
    Expression<String>? guestNameAr,
    Expression<DateTime>? scannedAt,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<DateTime>? syncedAt,
    Expression<String>? serverLabel,
    Expression<String>? message,
    Expression<bool>? seen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (eventId != null) 'event_id': eventId,
      if (guestId != null) 'guest_id': guestId,
      if (guestNameEn != null) 'guest_name_en': guestNameEn,
      if (guestNameAr != null) 'guest_name_ar': guestNameAr,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (serverLabel != null) 'server_label': serverLabel,
      if (message != null) 'message': message,
      if (seen != null) 'seen': seen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckinsCompanion copyWith({
    Value<String>? clientId,
    Value<int>? userId,
    Value<String>? username,
    Value<int>? eventId,
    Value<int>? guestId,
    Value<String>? guestNameEn,
    Value<String>? guestNameAr,
    Value<DateTime>? scannedAt,
    Value<CheckinState>? state,
    Value<int>? attempts,
    Value<DateTime?>? syncedAt,
    Value<String?>? serverLabel,
    Value<String?>? message,
    Value<bool>? seen,
    Value<int>? rowid,
  }) {
    return CheckinsCompanion(
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      eventId: eventId ?? this.eventId,
      guestId: guestId ?? this.guestId,
      guestNameEn: guestNameEn ?? this.guestNameEn,
      guestNameAr: guestNameAr ?? this.guestNameAr,
      scannedAt: scannedAt ?? this.scannedAt,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      syncedAt: syncedAt ?? this.syncedAt,
      serverLabel: serverLabel ?? this.serverLabel,
      message: message ?? this.message,
      seen: seen ?? this.seen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (guestId.present) {
      map['guest_id'] = Variable<int>(guestId.value);
    }
    if (guestNameEn.present) {
      map['guest_name_en'] = Variable<String>(guestNameEn.value);
    }
    if (guestNameAr.present) {
      map['guest_name_ar'] = Variable<String>(guestNameAr.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $CheckinsTable.$converterstate.toSql(state.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (serverLabel.present) {
      map['server_label'] = Variable<String>(serverLabel.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckinsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('eventId: $eventId, ')
          ..write('guestId: $guestId, ')
          ..write('guestNameEn: $guestNameEn, ')
          ..write('guestNameAr: $guestNameAr, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverLabel: $serverLabel, ')
          ..write('message: $message, ')
          ..write('seen: $seen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventsTable events = $EventsTable(this);
  late final $GuestsTable guests = $GuestsTable(this);
  late final $CheckinsTable checkins = $CheckinsTable(this);
  late final Index guestsEventToken = Index(
    'guests_event_token',
    'CREATE INDEX guests_event_token ON guests (event_id, token_sha256)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    events,
    guests,
    checkins,
    guestsEventToken,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      required int userId,
      required String titleEn,
      required String titleAr,
      required String venueEn,
      required String venueAr,
      required String startsLabel,
      required String timezone,
      required int guestCount,
      required int checkedInCount,
      Value<DateTime?> listDownloadedAt,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> titleEn,
      Value<String> titleAr,
      Value<String> venueEn,
      Value<String> venueAr,
      Value<String> startsLabel,
      Value<String> timezone,
      Value<int> guestCount,
      Value<int> checkedInCount,
      Value<DateTime?> listDownloadedAt,
    });

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleAr => $composableBuilder(
    column: $table.titleAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get venueEn => $composableBuilder(
    column: $table.venueEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get venueAr => $composableBuilder(
    column: $table.venueAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startsLabel => $composableBuilder(
    column: $table.startsLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guestCount => $composableBuilder(
    column: $table.guestCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkedInCount => $composableBuilder(
    column: $table.checkedInCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get listDownloadedAt => $composableBuilder(
    column: $table.listDownloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleAr => $composableBuilder(
    column: $table.titleAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get venueEn => $composableBuilder(
    column: $table.venueEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get venueAr => $composableBuilder(
    column: $table.venueAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startsLabel => $composableBuilder(
    column: $table.startsLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guestCount => $composableBuilder(
    column: $table.guestCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkedInCount => $composableBuilder(
    column: $table.checkedInCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get listDownloadedAt => $composableBuilder(
    column: $table.listDownloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  GeneratedColumn<String> get titleAr =>
      $composableBuilder(column: $table.titleAr, builder: (column) => column);

  GeneratedColumn<String> get venueEn =>
      $composableBuilder(column: $table.venueEn, builder: (column) => column);

  GeneratedColumn<String> get venueAr =>
      $composableBuilder(column: $table.venueAr, builder: (column) => column);

  GeneratedColumn<String> get startsLabel => $composableBuilder(
    column: $table.startsLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get guestCount => $composableBuilder(
    column: $table.guestCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get checkedInCount => $composableBuilder(
    column: $table.checkedInCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get listDownloadedAt => $composableBuilder(
    column: $table.listDownloadedAt,
    builder: (column) => column,
  );
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          EventRow,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
          EventRow,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> titleEn = const Value.absent(),
                Value<String> titleAr = const Value.absent(),
                Value<String> venueEn = const Value.absent(),
                Value<String> venueAr = const Value.absent(),
                Value<String> startsLabel = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> guestCount = const Value.absent(),
                Value<int> checkedInCount = const Value.absent(),
                Value<DateTime?> listDownloadedAt = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                userId: userId,
                titleEn: titleEn,
                titleAr: titleAr,
                venueEn: venueEn,
                venueAr: venueAr,
                startsLabel: startsLabel,
                timezone: timezone,
                guestCount: guestCount,
                checkedInCount: checkedInCount,
                listDownloadedAt: listDownloadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String titleEn,
                required String titleAr,
                required String venueEn,
                required String venueAr,
                required String startsLabel,
                required String timezone,
                required int guestCount,
                required int checkedInCount,
                Value<DateTime?> listDownloadedAt = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                userId: userId,
                titleEn: titleEn,
                titleAr: titleAr,
                venueEn: venueEn,
                venueAr: venueAr,
                startsLabel: startsLabel,
                timezone: timezone,
                guestCount: guestCount,
                checkedInCount: checkedInCount,
                listDownloadedAt: listDownloadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      EventRow,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
      EventRow,
      PrefetchHooks Function()
    >;
typedef $$GuestsTableCreateCompanionBuilder =
    GuestsCompanion Function({
      Value<int> id,
      required int eventId,
      required String nameEn,
      required String nameAr,
      required String rsvp,
      Value<String?> tableNumber,
      required String tokenSha256,
      required bool serverCheckedIn,
      Value<String?> serverCheckedInLabel,
    });
typedef $$GuestsTableUpdateCompanionBuilder =
    GuestsCompanion Function({
      Value<int> id,
      Value<int> eventId,
      Value<String> nameEn,
      Value<String> nameAr,
      Value<String> rsvp,
      Value<String?> tableNumber,
      Value<String> tokenSha256,
      Value<bool> serverCheckedIn,
      Value<String?> serverCheckedInLabel,
    });

class $$GuestsTableFilterComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rsvp => $composableBuilder(
    column: $table.rsvp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableNumber => $composableBuilder(
    column: $table.tableNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenSha256 => $composableBuilder(
    column: $table.tokenSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get serverCheckedIn => $composableBuilder(
    column: $table.serverCheckedIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverCheckedInLabel => $composableBuilder(
    column: $table.serverCheckedInLabel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rsvp => $composableBuilder(
    column: $table.rsvp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableNumber => $composableBuilder(
    column: $table.tableNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenSha256 => $composableBuilder(
    column: $table.tokenSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get serverCheckedIn => $composableBuilder(
    column: $table.serverCheckedIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverCheckedInLabel => $composableBuilder(
    column: $table.serverCheckedInLabel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get rsvp =>
      $composableBuilder(column: $table.rsvp, builder: (column) => column);

  GeneratedColumn<String> get tableNumber => $composableBuilder(
    column: $table.tableNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tokenSha256 => $composableBuilder(
    column: $table.tokenSha256,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get serverCheckedIn => $composableBuilder(
    column: $table.serverCheckedIn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverCheckedInLabel => $composableBuilder(
    column: $table.serverCheckedInLabel,
    builder: (column) => column,
  );
}

class $$GuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuestsTable,
          GuestRow,
          $$GuestsTableFilterComposer,
          $$GuestsTableOrderingComposer,
          $$GuestsTableAnnotationComposer,
          $$GuestsTableCreateCompanionBuilder,
          $$GuestsTableUpdateCompanionBuilder,
          (GuestRow, BaseReferences<_$AppDatabase, $GuestsTable, GuestRow>),
          GuestRow,
          PrefetchHooks Function()
        > {
  $$GuestsTableTableManager(_$AppDatabase db, $GuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
                Value<String> rsvp = const Value.absent(),
                Value<String?> tableNumber = const Value.absent(),
                Value<String> tokenSha256 = const Value.absent(),
                Value<bool> serverCheckedIn = const Value.absent(),
                Value<String?> serverCheckedInLabel = const Value.absent(),
              }) => GuestsCompanion(
                id: id,
                eventId: eventId,
                nameEn: nameEn,
                nameAr: nameAr,
                rsvp: rsvp,
                tableNumber: tableNumber,
                tokenSha256: tokenSha256,
                serverCheckedIn: serverCheckedIn,
                serverCheckedInLabel: serverCheckedInLabel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int eventId,
                required String nameEn,
                required String nameAr,
                required String rsvp,
                Value<String?> tableNumber = const Value.absent(),
                required String tokenSha256,
                required bool serverCheckedIn,
                Value<String?> serverCheckedInLabel = const Value.absent(),
              }) => GuestsCompanion.insert(
                id: id,
                eventId: eventId,
                nameEn: nameEn,
                nameAr: nameAr,
                rsvp: rsvp,
                tableNumber: tableNumber,
                tokenSha256: tokenSha256,
                serverCheckedIn: serverCheckedIn,
                serverCheckedInLabel: serverCheckedInLabel,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuestsTable,
      GuestRow,
      $$GuestsTableFilterComposer,
      $$GuestsTableOrderingComposer,
      $$GuestsTableAnnotationComposer,
      $$GuestsTableCreateCompanionBuilder,
      $$GuestsTableUpdateCompanionBuilder,
      (GuestRow, BaseReferences<_$AppDatabase, $GuestsTable, GuestRow>),
      GuestRow,
      PrefetchHooks Function()
    >;
typedef $$CheckinsTableCreateCompanionBuilder =
    CheckinsCompanion Function({
      required String clientId,
      required int userId,
      required String username,
      required int eventId,
      required int guestId,
      required String guestNameEn,
      required String guestNameAr,
      required DateTime scannedAt,
      required CheckinState state,
      Value<int> attempts,
      Value<DateTime?> syncedAt,
      Value<String?> serverLabel,
      Value<String?> message,
      Value<bool> seen,
      Value<int> rowid,
    });
typedef $$CheckinsTableUpdateCompanionBuilder =
    CheckinsCompanion Function({
      Value<String> clientId,
      Value<int> userId,
      Value<String> username,
      Value<int> eventId,
      Value<int> guestId,
      Value<String> guestNameEn,
      Value<String> guestNameAr,
      Value<DateTime> scannedAt,
      Value<CheckinState> state,
      Value<int> attempts,
      Value<DateTime?> syncedAt,
      Value<String?> serverLabel,
      Value<String?> message,
      Value<bool> seen,
      Value<int> rowid,
    });

class $$CheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guestNameEn => $composableBuilder(
    column: $table.guestNameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guestNameAr => $composableBuilder(
    column: $table.guestNameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CheckinState, CheckinState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverLabel => $composableBuilder(
    column: $table.serverLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guestNameEn => $composableBuilder(
    column: $table.guestNameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guestNameAr => $composableBuilder(
    column: $table.guestNameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverLabel => $composableBuilder(
    column: $table.serverLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<int> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<String> get guestNameEn => $composableBuilder(
    column: $table.guestNameEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guestNameAr => $composableBuilder(
    column: $table.guestNameAr,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CheckinState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get serverLabel => $composableBuilder(
    column: $table.serverLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);
}

class $$CheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckinsTable,
          CheckinRow,
          $$CheckinsTableFilterComposer,
          $$CheckinsTableOrderingComposer,
          $$CheckinsTableAnnotationComposer,
          $$CheckinsTableCreateCompanionBuilder,
          $$CheckinsTableUpdateCompanionBuilder,
          (
            CheckinRow,
            BaseReferences<_$AppDatabase, $CheckinsTable, CheckinRow>,
          ),
          CheckinRow,
          PrefetchHooks Function()
        > {
  $$CheckinsTableTableManager(_$AppDatabase db, $CheckinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<int> guestId = const Value.absent(),
                Value<String> guestNameEn = const Value.absent(),
                Value<String> guestNameAr = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
                Value<CheckinState> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String?> serverLabel = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckinsCompanion(
                clientId: clientId,
                userId: userId,
                username: username,
                eventId: eventId,
                guestId: guestId,
                guestNameEn: guestNameEn,
                guestNameAr: guestNameAr,
                scannedAt: scannedAt,
                state: state,
                attempts: attempts,
                syncedAt: syncedAt,
                serverLabel: serverLabel,
                message: message,
                seen: seen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required int userId,
                required String username,
                required int eventId,
                required int guestId,
                required String guestNameEn,
                required String guestNameAr,
                required DateTime scannedAt,
                required CheckinState state,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String?> serverLabel = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckinsCompanion.insert(
                clientId: clientId,
                userId: userId,
                username: username,
                eventId: eventId,
                guestId: guestId,
                guestNameEn: guestNameEn,
                guestNameAr: guestNameAr,
                scannedAt: scannedAt,
                state: state,
                attempts: attempts,
                syncedAt: syncedAt,
                serverLabel: serverLabel,
                message: message,
                seen: seen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckinsTable,
      CheckinRow,
      $$CheckinsTableFilterComposer,
      $$CheckinsTableOrderingComposer,
      $$CheckinsTableAnnotationComposer,
      $$CheckinsTableCreateCompanionBuilder,
      $$CheckinsTableUpdateCompanionBuilder,
      (CheckinRow, BaseReferences<_$AppDatabase, $CheckinsTable, CheckinRow>),
      CheckinRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$GuestsTableTableManager get guests =>
      $$GuestsTableTableManager(_db, _db.guests);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db, _db.checkins);
}
