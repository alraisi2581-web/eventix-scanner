import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import '../data/db/database.dart';
import '../providers.dart';
import '../services/checkin_service.dart';
import 'common.dart';

/// The answer after a scan, full screen: green = let in, amber = already in,
/// red = stop. The guest's name is the largest thing on the phone. Tap to
/// dismiss; a thin bar shows when it closes by itself.
class ScanResultView extends StatelessWidget {
  const ScanResultView({super.key, required this.outcome, required this.onDismiss});
  final ScanOutcome outcome;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.evx;
    final still = MediaQuery.of(context).disableAnimations;
    late final Color color;
    late final _Glyph glyph;
    late final String title;
    String? name, otherName, detail, table, rsvp;

    void guestLines(GuestRow g) {
      name = context.pick(g.nameEn, g.nameAr);
      otherName = context.other(g.nameEn, g.nameAr);
      if (g.tableNumber != null) table = l.table(g.tableNumber!);
      rsvp = switch (g.rsvp) {
        'Not Attending' => l.rsvpNotAttending,
        'No Reply' => l.rsvpNoReply,
        'Maybe' => l.rsvpMaybe,
        _ => null,
      };
    }

    switch (outcome) {
      case CheckedIn(:final guest):
        color = t.success;
        glyph = _Glyph.check;
        title = l.resultCheckedIn;
        guestLines(guest);
      case AlreadyCheckedIn(:final guest, :final timeLabel, :final scannedHereAt, :final onThisPhone):
        color = t.warning;
        glyph = _Glyph.again;
        final time = timeLabel ??
            (scannedHereAt != null ? context.clock(scannedHereAt) : null);
        title = time == null ? l.resultAlready : l.resultAlreadyAt(context.ltr(time));
        if (onThisPhone && scannedHereAt != null && timeLabel == null) {
          detail = l.resultScannedHere(context.clock(scannedHereAt));
        }
        guestLines(guest);
        rsvp = null;
      case WrongEvent(:final event):
        color = t.danger;
        glyph = _Glyph.stop;
        title = l.resultWrongEvent;
        detail = l.resultWrongEventHint(context.pick(event.titleEn, event.titleAr));
      case NotOnList():
        color = t.danger;
        glyph = _Glyph.stop;
        title = l.resultNotOnList;
        detail = l.resultNotOnListHint;
      case NotAnInvitation():
        color = t.danger;
        glyph = _Glyph.stop;
        title = l.resultNotInvitation;
        detail = l.resultNotInvitationHint;
    }

    final nameStyle = context.isArabic
        ? evxText(36, family: arabic, weight: FontWeight.w700, color: Colors.white, height: 1.35)
        : evxDisplay(38, color: Colors.white);

    return Semantics(
      liveRegion: true,
      button: true,
      label: [title, ?name].join(', '),
      child: GestureDetector(
        key: const Key('scan-result'),
        onTap: onDismiss,
        child: Material(
          color: color,
          child: Stack(fit: StackFit.expand, children: [
            // the web stat cards' translucent circle, larger
            PositionedDirectional(
              end: -90,
              bottom: -60,
              child: _Circle(size: 300, alpha: .09),
            ),
            PositionedDirectional(
              start: -70,
              top: -50,
              child: _Circle(size: 200, alpha: .06),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
                child: Column(children: [
                  const Spacer(flex: 3),
                  _AnimatedGlyph(glyph: glyph, still: still),
                  const SizedBox(height: 22),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: evxText(20,
                          weight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: .92))),
                  if (name != null) ...[
                    const SizedBox(height: 14),
                    Text(name!, textAlign: TextAlign.center, style: nameStyle),
                  ],
                  if (otherName != null) ...[
                    const SizedBox(height: 4),
                    Text(otherName!,
                        textAlign: TextAlign.center,
                        style: evxText(20, color: Colors.white.withValues(alpha: .8))),
                  ],
                  if (table != null || rsvp != null) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (table != null)
                          _Pill(icon: Icons.table_restaurant_outlined, text: table!),
                        if (rsvp != null)
                          _Pill(icon: Icons.warning_amber_rounded, text: rsvp!, strong: true),
                      ],
                    ),
                  ],
                  if (detail != null) ...[
                    const SizedBox(height: 18),
                    Text(detail,
                        textAlign: TextAlign.center,
                        style: evxText(17, color: Colors.white, height: 1.45)),
                  ],
                  const Spacer(flex: 4),
                  _Countdown(still: still),
                  const SizedBox(height: 12),
                  Text(l.tapToContinue,
                      style: evxText(14, color: Colors.white.withValues(alpha: .75))),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

enum _Glyph { check, again, stop }

/// The result's mark, drawn in once (a check that writes itself, a turn, a cross).
class _AnimatedGlyph extends StatelessWidget {
  const _AnimatedGlyph({required this.glyph, required this.still});
  final _Glyph glyph;
  final bool still;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => Transform.scale(
          scale: .82 + .18 * Curves.easeOutBack.transform(v),
          child: Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .16),
              border: Border.all(color: Colors.white.withValues(alpha: .55), width: 3),
            ),
            child: glyph == _Glyph.again
                ? Icon(Icons.replay_rounded, size: 64, color: Colors.white.withValues(alpha: v))
                : CustomPaint(painter: _GlyphPainter(glyph, v)),
          ),
        ),
      );
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.progress);
  final _Glyph glyph;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final path = Path();
    switch (glyph) {
      case _Glyph.check:
        path
          ..moveTo(w * .29, w * .52)
          ..lineTo(w * .44, w * .66)
          ..lineTo(w * .72, w * .37);
      case _Glyph.stop:
        path
          ..moveTo(w * .35, w * .35)
          ..lineTo(w * .65, w * .65)
          ..moveTo(w * .65, w * .35)
          ..lineTo(w * .35, w * .65);
      case _Glyph.again:
        return; // drawn as an icon
    }
    // draw the first [progress] of the path's length: the mark writes itself
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * progress), p);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.progress != progress || old.glyph != glyph;
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.alpha});
  final double size;
  final double alpha;
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, this.strong = false});
  final IconData icon;
  final String text;
  final bool strong;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: strong
              ? Colors.black.withValues(alpha: .24)
              : Colors.white.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(width: 7),
          // wraps on a narrow phone or with a large system font size
          Flexible(
              child: Text(text,
                  style: evxText(16, weight: FontWeight.w600, color: Colors.white))),
        ]),
      );
}

/// How long until the result closes by itself.
class _Countdown extends StatelessWidget {
  const _Countdown({required this.still});
  final bool still;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 120,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: still ? 1 : 0),
          duration: AppConfig.resultOnScreen,
          builder: (_, v, _) => ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 3,
              color: Colors.white.withValues(alpha: .85),
              backgroundColor: Colors.white.withValues(alpha: .2),
            ),
          ),
        ),
      );
}

/// "Online · all uploaded" / "Offline · 3 waiting" / "Sign in again to upload".
/// Tap to try uploading now.
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.evx;
    final status = ref.watch(syncProvider);
    final pending = ref.watch(pendingCountProvider).valueOrNull ?? 0;

    final (IconData icon, Color color, String text) = switch (status) {
      _ when status.needsSignIn => (Icons.lock_clock_rounded, t.danger, l.statusSignIn),
      _ when status.syncing && pending > 0 =>
        (Icons.cloud_upload_rounded, t.info, l.statusUploading),
      _ when status.online == false && pending > 0 =>
        (Icons.cloud_off_rounded, t.warning, l.statusOffline(pending)),
      _ when status.online == false =>
        (Icons.cloud_off_rounded, t.warning, l.statusOfflineNoneWaiting),
      _ when pending > 0 =>
        (Icons.cloud_queue_rounded, t.warning, l.statusWaiting(pending)),
      _ when status.online == null =>
        (Icons.cloud_sync_rounded, t.info, l.statusConnecting),
      _ => (Icons.cloud_done_rounded, t.success, l.statusAllUploaded),
    };
    return Material(
      key: const Key('sync-status'),
      color: t.surface,
      elevation: 0,
      shape: StadiumBorder(side: BorderSide(color: color.withValues(alpha: .35))),
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => ref.read(syncProvider.notifier).kick(refreshList: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 7),
            Text(text, style: evxText(13.5, weight: FontWeight.w600, color: color)),
          ]),
        ),
      ),
    );
  }
}

/// Tells door staff, until they tap OK, that a check-in from this phone did
/// not count: the guest was already checked in when it reached the server.
class ConflictBanner extends ConsumerWidget {
  const ConflictBanner({super.key, required this.eventId});
  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unseen = ref.watch(unseenProvider(eventId)).valueOrNull ?? const [];
    if (unseen.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    final t = context.evx;
    final c = unseen.first;
    final name = context.pick(c.guestNameEn, c.guestNameAr);
    final text = c.state == CheckinState.conflict
        ? l.conflictBanner(name, c.serverLabel == null ? l.earlierTime : context.ltr(c.serverLabel!))
        : l.rejectedBanner(name, l.reasonRemoved);
    return Container(
      key: const Key('conflict-banner'),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: t.shadowMd,
      ),
      child: EvxAlert(
        text: unseen.length > 1 ? '$text (+${unseen.length - 1})' : text,
        icon: Icons.warning_amber_rounded,
        action: TextButton(
          onPressed: () => ref.read(databaseProvider).markSeen(c.clientId),
          child: Text(l.ok),
        ),
      ),
    );
  }
}
