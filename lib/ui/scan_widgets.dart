import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../providers.dart';
import '../services/checkin_service.dart';
import 'common.dart';

/// The full-screen answer after a scan, like the web scanner's overlay:
/// green = let in, amber = already in, red = stop. Tap to dismiss.
class ScanResultView extends StatelessWidget {
  const ScanResultView({super.key, required this.outcome, required this.onDismiss});
  final ScanOutcome outcome;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    late final Color color;
    late final IconData icon;
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
        color = EvxColors.success;
        icon = Icons.check_circle;
        title = l.resultCheckedIn;
        guestLines(guest);
      case AlreadyCheckedIn(:final guest, :final timeLabel, :final scannedHereAt, :final onThisPhone):
        color = EvxColors.warning;
        icon = Icons.replay_circle_filled;
        final time = timeLabel ??
            (scannedHereAt != null ? context.clock(scannedHereAt) : null);
        title = time == null ? l.resultAlready : l.resultAlreadyAt(time);
        if (onThisPhone && scannedHereAt != null && timeLabel == null) {
          detail = l.resultScannedHere(context.clock(scannedHereAt));
        }
        guestLines(guest);
        rsvp = null;
      case WrongEvent(:final event):
        color = EvxColors.danger;
        icon = Icons.event_busy;
        title = l.resultWrongEvent;
        detail = l.resultWrongEventHint(context.pick(event.titleEn, event.titleAr));
      case NotOnList():
        color = EvxColors.danger;
        icon = Icons.person_off;
        title = l.resultNotOnList;
        detail = l.resultNotOnListHint;
      case NotAnInvitation():
        color = EvxColors.danger;
        icon = Icons.qr_code_2;
        title = l.resultNotInvitation;
        detail = l.resultNotInvitationHint;
    }

    const white = TextStyle(color: Colors.white);
    return Semantics(
      liveRegion: true,
      button: true,
      label: [title, ?name].join(', '),
      child: GestureDetector(
        key: const Key('scan-result'),
        onTap: onDismiss,
        child: Container(
          color: color,
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 112, color: Colors.white),
                const SizedBox(height: 16),
                Text(title,
                    textAlign: TextAlign.center,
                    style: white.copyWith(fontSize: 26, fontWeight: FontWeight.w700)),
                if (name != null) ...[
                  const SizedBox(height: 20),
                  Text(name!,
                      textAlign: TextAlign.center,
                      style: white.copyWith(fontSize: 30, fontWeight: FontWeight.w800)),
                ],
                if (otherName != null)
                  Text(otherName!,
                      textAlign: TextAlign.center,
                      style: white.copyWith(fontSize: 20)),
                if (table != null) ...[
                  const SizedBox(height: 12),
                  Text(table!, style: white.copyWith(fontSize: 20)),
                ],
                if (rsvp != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.warning_amber, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(rsvp!, style: white.copyWith(fontSize: 16)),
                    ]),
                  ),
                ],
                if (detail != null) ...[
                  const SizedBox(height: 16),
                  Text(detail,
                      textAlign: TextAlign.center,
                      style: white.copyWith(fontSize: 17)),
                ],
                const SizedBox(height: 32),
                Text(l.tapToContinue, style: white.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Online · all uploaded" / "Offline · 3 waiting" / "Sign in again to upload".
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final status = ref.watch(syncProvider);
    final pending = ref.watch(pendingCountProvider).valueOrNull ?? 0;

    final (IconData icon, Color color, String text) = switch (status) {
      _ when status.needsSignIn => (Icons.lock_clock, EvxColors.danger, l.statusSignIn),
      _ when status.syncing && pending > 0 =>
        (Icons.cloud_upload, EvxColors.navy, l.statusUploading),
      _ when status.online == false && pending > 0 =>
        (Icons.cloud_off, EvxColors.warning, l.statusOffline(pending)),
      _ when status.online == false =>
        (Icons.cloud_off, EvxColors.warning, l.statusOfflineNoneWaiting),
      _ when pending > 0 =>
        (Icons.cloud_queue, EvxColors.warning, l.statusWaiting(pending)),
      _ when status.online == null =>
        (Icons.cloud_sync, EvxColors.navy, l.statusConnecting),
      _ => (Icons.cloud_done, EvxColors.success, l.statusAllUploaded),
    };
    return Material(
      key: const Key('sync-status'),
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(syncProvider.notifier).kick(refreshList: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
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
    final c = unseen.first;
    final name = context.pick(c.guestNameEn, c.guestNameAr);
    final text = c.state == CheckinState.conflict
        ? l.conflictBanner(name, c.serverLabel ?? l.earlierTime)
        : l.rejectedBanner(name, l.reasonRemoved);
    return Material(
      key: const Key('conflict-banner'),
      color: const Color(0xFFFDF5E6),
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 8),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: EvxColors.warning, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              unseen.length > 1 ? '$text (+${unseen.length - 1})' : text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(databaseProvider).markSeen(c.clientId),
            child: Text(l.ok),
          ),
        ]),
      ),
    );
  }
}
