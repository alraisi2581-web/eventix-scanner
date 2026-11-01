// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ماسح إيفنتكس';

  @override
  String get signInTitle => 'سجّل الدخول لتسجيل حضور الضيوف';

  @override
  String get signInHint => 'استخدم حساب الماسح الذي زوّدتك به إيفنتكس.';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get usernameRequired => 'أدخل اسم المستخدم';

  @override
  String get usernameTooLong => 'اسم المستخدم طويل جدًا';

  @override
  String get passwordRequired => 'أدخل كلمة المرور';

  @override
  String pendingFromBefore(int count, String username) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تسجيل حضور للمستخدم $username بانتظار الرفع.',
      few: '$count تسجيلات حضور للمستخدم $username بانتظار الرفع.',
      two: 'تسجيلا حضور للمستخدم $username بانتظار الرفع.',
      one: 'تسجيل حضور واحد للمستخدم $username بانتظار الرفع.',
    );
    return '$_temp0 سجّل الدخول باسم $username لإرسالها.';
  }

  @override
  String get errorWrongPassword => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get errorRoleNotAllowed =>
      'هذا الحساب لا يمكنه تسجيل حضور الضيوف. سجّل الدخول بحساب ماسح.';

  @override
  String get errorPasswordChange =>
      'كلمة مرورك مؤقتة. سجّل الدخول مرة واحدة في eventix.om/login لاختيار كلمة مرورك، ثم سجّل الدخول هنا بها.';

  @override
  String get errorTooManyAttempts =>
      'محاولات دخول فاشلة كثيرة. حاول مجددًا بعد 30 دقيقة.';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال بإيفنتكس. تحقّق من الواي فاي أو بيانات الجوال وحاول مجددًا.';

  @override
  String get errorRateLimited => 'طلبات كثيرة. انتظر دقيقة وحاول مجددًا.';

  @override
  String get errorForbidden => 'ليس لديك صلاحية الوصول إلى هذه الفعالية.';

  @override
  String get errorServer => 'تعذّر على إيفنتكس الرد. حاول مجددًا بعد قليل.';

  @override
  String get yourEvents => 'فعالياتك';

  @override
  String signedInAs(String username) {
    return 'مسجّل الدخول باسم $username';
  }

  @override
  String get noEventsTitle => 'لا توجد فعاليات بعد';

  @override
  String get noEventsBody =>
      'حسابك غير مرتبط بأي فعالية. اطلب من مسؤول إيفنتكس منحك الصلاحية، ثم اسحب للأسفل للتحديث.';

  @override
  String get offlineSavedList => 'غير متصل — يُعرض المحفوظ على هذا الهاتف.';

  @override
  String get retry => 'حاول مجددًا';

  @override
  String guestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ضيفًا',
      few: '$count ضيوف',
      two: 'ضيفان',
      one: 'ضيف واحد',
      zero: 'لا ضيوف',
    );
    return '$_temp0';
  }

  @override
  String get listSaved => 'قائمة الضيوف محفوظة على هذا الهاتف';

  @override
  String get listNotSaved => 'لم تُنزَّل قائمة الضيوف بعد';

  @override
  String get downloadingList => 'جارٍ تنزيل قائمة الضيوف…';

  @override
  String get downloadNeedsNetwork =>
      'اتصل بالإنترنت مرة واحدة لتنزيل قائمة ضيوف هذه الفعالية، وبعدها يعمل المسح دون اتصال.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutPendingTitle => 'تسجيلات حضور لم تُرفع بعد';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تسجيل حضور لم يصل إلى إيفنتكس.',
      few: '$count تسجيلات حضور لم تصل إلى إيفنتكس.',
      two: 'تسجيلا حضور لم يصلا إلى إيفنتكس.',
      one: 'تسجيل حضور واحد لم يصل إلى إيفنتكس.',
    );
    return '$_temp0 ستبقى على هذا الهاتف وتُرفع عند تسجيل الدخول مجددًا. هل تريد تسجيل الخروج؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسنًا';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get statusAllUploaded => 'متصل · تم رفع الكل';

  @override
  String get statusUploading => 'جارٍ الرفع…';

  @override
  String statusWaiting(int count) {
    return '$count بانتظار الرفع';
  }

  @override
  String statusOffline(int count) {
    return 'غير متصل · $count بانتظار الرفع';
  }

  @override
  String get statusOfflineNoneWaiting => 'غير متصل · المسح يعمل';

  @override
  String get statusSignIn => 'سجّل الدخول مجددًا للرفع';

  @override
  String get statusConnecting => 'جارٍ الاتصال…';

  @override
  String checkedInOf(int checked, int total) {
    return 'حضر $checked من $total';
  }

  @override
  String get resultCheckedIn => 'تم تسجيل الحضور';

  @override
  String get resultAlready => 'سبق تسجيل حضوره';

  @override
  String resultAlreadyAt(String time) {
    return 'سبق تسجيل حضوره · $time';
  }

  @override
  String resultScannedHere(String time) {
    return 'مُسح على هذا الهاتف الساعة $time';
  }

  @override
  String get resultNotOnList => 'ليس في قائمة الضيوف';

  @override
  String get resultNotOnListHint =>
      'هذه الدعوة ليست لهذه الفعالية، أو أُزيل الضيف من القائمة.';

  @override
  String get resultWrongEvent => 'دعوة لفعالية أخرى';

  @override
  String resultWrongEventHint(String event) {
    return 'رمز QR هذا لفعالية «$event».';
  }

  @override
  String get resultNotInvitation => 'ليست دعوة إيفنتكس';

  @override
  String get resultNotInvitationHint =>
      'اطلب من الضيف رمز QR الموجود في دعوته.';

  @override
  String get rsvpNotAttending => 'الرد: لن يحضر';

  @override
  String get rsvpNoReply => 'الرد: لم يرد';

  @override
  String get rsvpMaybe => 'الرد: ربما';

  @override
  String table(String table) {
    return 'الطاولة $table';
  }

  @override
  String get tapToContinue => 'اضغط للمتابعة';

  @override
  String get searchByName => 'البحث بالاسم';

  @override
  String get activity => 'تسجيلات هذا الهاتف';

  @override
  String get torch => 'الكشاف';

  @override
  String get cameraDeniedTitle => 'الوصول إلى الكاميرا متوقف';

  @override
  String get cameraDeniedBody =>
      'يحتاج الماسح إلى الكاميرا لقراءة رموز QR في الدعوات. فعّل وصول ماسح إيفنتكس إلى الكاميرا من الإعدادات، أو سجّل حضور الضيوف بالاسم.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get cameraErrorTitle => 'تعذّر تشغيل الكاميرا';

  @override
  String get cameraErrorBody =>
      'أغلق التطبيقات الأخرى التي تستخدم الكاميرا وحاول مجددًا، أو سجّل حضور الضيوف بالاسم.';

  @override
  String get searchHint => 'الاسم أو رقم الطاولة';

  @override
  String get searchTooShort => 'اكتب حرفين على الأقل، أو رقم طاولة';

  @override
  String searchNoMatch(String query) {
    return 'لا يوجد ضيف يطابق «$query»';
  }

  @override
  String checkInConfirm(String name) {
    return 'تسجيل حضور $name؟';
  }

  @override
  String get checkIn => 'تسجيل الحضور';

  @override
  String get badgeIn => 'حضر';

  @override
  String get activityEmpty => 'لا توجد تسجيلات حضور على هذا الهاتف بعد.';

  @override
  String get statePending => 'بانتظار الرفع';

  @override
  String stateConfirmed(String time) {
    return 'تم الرفع · سُجّل الحضور $time';
  }

  @override
  String stateConflict(String time) {
    return 'سبق تسجيل حضوره الساعة $time — لم يُحتسب مسح هذا الهاتف';
  }

  @override
  String stateRejected(String reason) {
    return 'لم يقبله إيفنتكس: $reason';
  }

  @override
  String conflictBanner(String name, String time) {
    return 'سبق تسجيل حضور $name الساعة $time. لم يُحتسب مسح هذا الهاتف.';
  }

  @override
  String rejectedBanner(String name, String reason) {
    return 'لم يُقبل تسجيل حضور $name: $reason';
  }

  @override
  String get reasonRemoved => 'الضيف لم يعد في القائمة';

  @override
  String get undoHint => 'لإلغاء تسجيل حضور، تواصل مع مسؤول إيفنتكس.';

  @override
  String get uploadNow => 'رفع الآن';

  @override
  String get earlierTime => 'في وقت سابق';
}
