import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/config.dart';
import '../providers.dart';
import '../services/checkin_service.dart';
import 'activity_screen.dart';
import 'common.dart';
import 'guest_search_screen.dart';
import 'scan_widgets.dart';

/// The door: camera, the scan result, upload status, and the way to search by
/// name. Scans are decided on the phone (CheckinService) and uploaded in the
/// background (SyncService).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, required this.eventId});
  final int eventId;
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  // started and stopped by hand, following the app lifecycle (mobile_scanner README)
  final _camera = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );
  StreamSubscription<BarcodeCapture>? _barcodes;
  late final SyncController _sync;

  ScanOutcome? _outcome;
  Timer? _hide;
  String? _lastCode;
  DateTime _lastCodeAt = DateTime(2000);
  bool _deciding = false;

  /// Set when door staff go to Settings to allow the camera: the next return
  /// to the app tries the camera once more. Without it a denial is final for
  /// this screen — retrying on every resume re-opened Android's permission
  /// dialog, whose own resume retried again (the screen flickered).
  bool _retryCameraOnResume = false;

  bool get _cameraAllowed => _camera.value.hasCameraPermission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sync = ref.read(syncProvider.notifier)..activeEventId = widget.eventId;
    _sync.kick(refreshList: true);
    _startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sync.activeEventId = null;
    _hide?.cancel();
    unawaited(_barcodes?.cancel());
    unawaited(_camera.dispose());
    super.dispose();
  }

  void _startCamera() {
    _barcodes ??= _camera.barcodes.listen(_onBarcode);
    unawaited(_camera.start().catchError((_) {})); // errors show in errorBuilder
  }

  void _stopCamera() {
    unawaited(_barcodes?.cancel());
    _barcodes = null;
    unawaited(_camera.stop());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_cameraAllowed || _retryCameraOnResume) {
          _retryCameraOnResume = false;
          _startCamera();
        }
        _sync.kick(refreshList: true);
      case AppLifecycleState.inactive:
        if (_cameraAllowed) _stopCamera();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onBarcode(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || _outcome != null || _deciding) return;
    final now = DateTime.now();
    // the camera reports the same code many times a second
    if (raw == _lastCode && now.difference(_lastCodeAt) < AppConfig.sameCodeCooldown) {
      return;
    }
    _lastCode = raw;
    _lastCodeAt = now;
    final session = ref.read(authProvider).valueOrNull;
    if (session == null) return;
    _deciding = true;
    try {
      final outcome = await ref
          .read(checkinServiceProvider)
          .scan(session, widget.eventId, raw);
      _show(outcome);
    } finally {
      _deciding = false;
    }
  }

  void _show(ScanOutcome outcome) {
    if (!mounted) return;
    switch (outcome) {
      case CheckedIn():
        HapticFeedback.mediumImpact();
        _sync.kick();
      case AlreadyCheckedIn():
        HapticFeedback.heavyImpact();
      default:
        HapticFeedback.vibrate();
    }
    setState(() => _outcome = outcome);
    _hide?.cancel();
    _hide = Timer(AppConfig.resultOnScreen, _dismiss);
  }

  void _dismiss() {
    _hide?.cancel();
    if (mounted) setState(() => _outcome = null);
    _lastCodeAt = DateTime.now(); // the same QR still in front of the camera isn't re-read at once
  }

  Future<void> _searchByName() async {
    final hadCamera = _cameraAllowed;
    if (hadCamera) _stopCamera();
    final outcome = await Navigator.of(context).push<ScanOutcome>(
        MaterialPageRoute(builder: (_) => GuestSearchScreen(eventId: widget.eventId)));
    if (!mounted) return;
    if (hadCamera) _startCamera();
    if (outcome != null) _show(outcome);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.evx;
    final event = ref.watch(eventProvider(widget.eventId)).valueOrNull;
    final counts = ref.watch(countsProvider(widget.eventId)).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event == null ? '' : context.pick(event.titleEn, event.titleAr),
              overflow: TextOverflow.ellipsis),
          if (counts != null)
            Text(l.checkedInOf(counts.checkedIn, counts.total),
                key: const Key('checked-in-count'),
                style: evxText(13, color: Colors.white70)),
        ]),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _camera,
            builder: (_, cam, _) => IconButton(
              tooltip: l.torch,
              onPressed: cam.isRunning ? () => _camera.toggleTorch() : null,
              icon: Icon(
                cam.torchState == TorchState.on
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_outlined,
                color: cam.torchState == TorchState.on ? t.gold : null,
              ),
            ),
          ),
          IconButton(
            tooltip: l.activity,
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => ActivityScreen(eventId: widget.eventId))),
          ),
          const SizedBox(width: 4),
        ],
        // how full the room is, as the web's progress bar
        bottom: counts == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: EvxProgress(
                  height: 3,
                  value: counts.total == 0 ? 0 : counts.checkedIn / counts.total,
                  color: t.gold,
                  track: Colors.white.withValues(alpha: .12),
                ),
              ),
      ),
      // expand: some children are plain (not Positioned) when hidden, which would shrink a default Stack to nothing
      body: Stack(fit: StackFit.expand, children: [
        Positioned.fill(
          child: MobileScanner(
            controller: _camera,
            errorBuilder: (context, error) => _CameraProblem(
              denied: error.errorCode == MobileScannerErrorCode.permissionDenied,
              onSearch: _searchByName,
              onOpenSettings: () {
                _retryCameraOnResume = true;
                AppSettings.openAppSettings();
              },
            ),
          ),
        ),
        // the scan window only over a working camera, never over the problem message
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: _camera,
          builder: (_, cam, _) => cam.isRunning
              ? Positioned.fill(child: IgnorePointer(child: _Viewfinder(hint: l.scanHint)))
              : const SizedBox.shrink(),
        ),
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: Column(children: [
            const SyncStatusChip(),
            const SizedBox(height: 10),
            ConflictBanner(eventId: widget.eventId),
          ]),
        ),
        // the camera-problem message has its own Search by name button
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: _camera,
          builder: (_, cam, _) => cam.error != null
              ? const SizedBox.shrink()
              : Positioned(
                  left: 20,
                  right: 20,
                  bottom: 22,
                  child: SafeArea(
                    child: FilledButton.icon(
                      key: const Key('search-by-name'),
                      style: FilledButton.styleFrom(
                        backgroundColor: t.gold, // the web's .btn-gold
                        minimumSize: const Size.fromHeight(54),
                      ),
                      onPressed: _searchByName,
                      icon: const Icon(Icons.person_search_rounded),
                      label: Text(l.searchByName),
                    ),
                  ),
                ),
        ),
        if (_outcome != null)
          Positioned.fill(
              child: ScanResultView(outcome: _outcome!, onDismiss: _dismiss)),
      ]),
    );
  }
}

/// The scan window: the camera dimmed around a clear square with gold corner
/// brackets, and a line saying what to do.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.hint});
  final String hint;
  @override
  Widget build(BuildContext context) {
    final gold = context.evx.gold;
    return LayoutBuilder(builder: (context, box) {
      final side = (box.maxWidth * .68).clamp(200.0, 300.0);
      final window = Rect.fromCenter(
          center: Offset(box.maxWidth / 2, box.maxHeight * .44),
          width: side,
          height: side);
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _WindowPainter(window, gold))),
        Positioned(
          left: 24,
          right: 24,
          top: window.bottom + 22,
          child: Text(hint,
              textAlign: TextAlign.center,
              style: evxText(15, weight: FontWeight.w500, color: Colors.white, height: 1.4)
                  .copyWith(shadows: const [Shadow(blurRadius: 8, color: Colors.black54)])),
        ),
      ]);
    });
  }
}

class _WindowPainter extends CustomPainter {
  _WindowPainter(this.window, this.gold);
  final Rect window;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(window, const Radius.circular(22));
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size),
          Path()..addRRect(hole)),
      Paint()..color = const Color(0xA60B1222), // navy-black scrim, 65%
    );
    final p = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const arm = 34.0, r = 22.0;
    final corners = [
      (window.left, window.top, 1.0, 1.0),
      (window.right, window.top, -1.0, 1.0),
      (window.left, window.bottom, 1.0, -1.0),
      (window.right, window.bottom, -1.0, -1.0),
    ];
    // one bracket per corner: a straight arm, the rounded corner, a straight arm
    for (final (cx, cy, sx, sy) in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(cx, cy + sy * (r + arm))
          ..lineTo(cx, cy + sy * r)
          ..quadraticBezierTo(cx, cy, cx + sx * r, cy)
          ..lineTo(cx + sx * (r + arm), cy),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_WindowPainter old) => old.window != window || old.gold != gold;
}

/// Camera access denied (or the camera failed): explain, offer Settings,
/// and keep the door working by name.
class _CameraProblem extends StatelessWidget {
  const _CameraProblem(
      {required this.denied, required this.onSearch, required this.onOpenSettings});
  final bool denied;
  final VoidCallback onSearch;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ColoredBox(
      color: context.evx.bg,
      child: MessageView(
        key: const Key('camera-problem'),
        icon: denied ? Icons.no_photography_outlined : Icons.videocam_off_outlined,
        tone: EvxTone.warning,
        title: denied ? l.cameraDeniedTitle : l.cameraErrorTitle,
        body: denied ? l.cameraDeniedBody : l.cameraErrorBody,
        actions: [
          if (denied)
            FilledButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
              label: Text(l.openSettings),
            ),
          OutlinedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.person_search_rounded),
            label: Text(l.searchByName),
          ),
        ],
      ),
    );
  }
}
