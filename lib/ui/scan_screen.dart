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
        // also after the user turned camera access on in Settings
        _startCamera();
        _sync.kick(refreshList: true);
      case AppLifecycleState.inactive:
        if (_camera.value.hasCameraPermission) _stopCamera();
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
    _stopCamera();
    final outcome = await Navigator.of(context).push<ScanOutcome>(
        MaterialPageRoute(builder: (_) => GuestSearchScreen(eventId: widget.eventId)));
    if (!mounted) return;
    _startCamera();
    if (outcome != null) _show(outcome);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final event = ref.watch(eventProvider(widget.eventId)).valueOrNull;
    final counts = ref.watch(countsProvider(widget.eventId)).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event == null ? '' : context.pick(event.titleEn, event.titleAr),
              overflow: TextOverflow.ellipsis),
          if (counts != null)
            Text(l.checkedInOf(counts.checkedIn, counts.total),
                key: const Key('checked-in-count'),
                style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ]),
        actions: [
          IconButton(
            tooltip: l.torch,
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _camera.toggleTorch(),
          ),
          IconButton(
            tooltip: l.activity,
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => ActivityScreen(eventId: widget.eventId))),
          ),
        ],
      ),
      body: Stack(children: [
        Positioned.fill(
          child: MobileScanner(
            controller: _camera,
            errorBuilder: (context, error) => _CameraProblem(
              denied: error.errorCode == MobileScannerErrorCode.permissionDenied,
              onSearch: _searchByName,
            ),
          ),
        ),
        const Positioned.fill(child: IgnorePointer(child: _Viewfinder())),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(children: [
            const SyncStatusChip(),
            const SizedBox(height: 8),
            ConflictBanner(eventId: widget.eventId),
          ]),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: SafeArea(
            child: FilledButton.icon(
              key: const Key('search-by-name'),
              onPressed: _searchByName,
              icon: const Icon(Icons.search),
              label: Text(l.searchByName),
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

/// A square guide over the camera where the QR should go.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: EvxColors.gold, width: 4),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
}

/// Camera access denied (or the camera failed): explain, offer Settings,
/// and keep the door working by name.
class _CameraProblem extends StatelessWidget {
  const _CameraProblem({required this.denied, required this.onSearch});
  final bool denied;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ColoredBox(
      color: EvxColors.bg,
      child: MessageView(
        key: const Key('camera-problem'),
        icon: denied ? Icons.no_photography : Icons.videocam_off,
        color: EvxColors.warning,
        title: denied ? l.cameraDeniedTitle : l.cameraErrorTitle,
        body: denied ? l.cameraDeniedBody : l.cameraErrorBody,
        actions: [
          if (denied)
            FilledButton.icon(
              onPressed: () => AppSettings.openAppSettings(),
              icon: const Icon(Icons.settings),
              label: Text(l.openSettings),
            ),
          OutlinedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            label: Text(l.searchByName),
          ),
          const SizedBox(height: 80), // clear of the search button below
        ],
      ),
    );
  }
}
