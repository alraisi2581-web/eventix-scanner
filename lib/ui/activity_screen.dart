import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../providers.dart';
import 'common.dart';

/// Every check-in made on this phone for the event and where it stands:
/// waiting to upload, uploaded, or did not count (someone was first).
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key, required this.eventId});
  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final rows = ref.watch(activityProvider(eventId));
    final pending = ref.watch(pendingCountProvider).valueOrNull ?? 0;
    final sync = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.activity)),
      body: rows.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            message: l.errorServer,
            onRetry: () => ref.invalidate(activityProvider(eventId))),
        data: (list) => list.isEmpty
            ? MessageView(
                icon: Icons.history_rounded,
                tone: EvxTone.neutral,
                title: l.activityEmpty,
                body: l.undoHint)
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(syncProvider.notifier).syncNow(refreshList: true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    _Summary(rows: list),
                    const SizedBox(height: 14),
                    EvxCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        for (final (i, r) in list.indexed) ...[
                          if (i > 0) const Divider(height: 1),
                          _Row(row: r),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Text(l.undoHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
      ),
      floatingActionButton: pending == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: sync.syncing
                  ? null
                  : () => ref.read(syncProvider.notifier).kick(refreshList: true),
              icon: const Icon(Icons.cloud_upload_rounded),
              label: Text(l.uploadNow),
            ),
    );
  }
}

/// Counts by state, as the web's stat cards: uploaded · waiting · didn't count.
class _Summary extends StatelessWidget {
  const _Summary({required this.rows});
  final List<CheckinRow> rows;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.evx;
    int n(CheckinState s) => rows.where((r) => r.state == s).length;
    final tiles = [
      (n(CheckinState.confirmed), l.summaryUploaded, t.success),
      (n(CheckinState.pending), l.summaryWaiting, t.warning),
      (n(CheckinState.conflict) + n(CheckinState.rejected), l.summaryNotCounted, t.danger),
    ];
    return Row(children: [
      for (final (i, (count, label, color)) in tiles.indexed) ...[
        if (i > 0) const SizedBox(width: 10),
        Expanded(
          // coloured only when it counts something; an empty one stays quiet
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: count > 0 ? color : t.surface2,
              borderRadius: BorderRadius.circular(radiusMd),
              border: count > 0 ? null : Border.all(color: t.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$count', style: evxDisplay(26, color: count > 0 ? Colors.white : t.text3)),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: evxText(12.5,
                      weight: FontWeight.w500,
                      color: count > 0 ? Colors.white.withValues(alpha: .9) : t.text3)),
            ]),
          ),
        ),
      ],
    ]);
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.row});
  final CheckinRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.evx;
    final time = row.serverLabel == null ? l.earlierTime : context.ltr(row.serverLabel!);
    final (IconData icon, EvxTone tone, String badge, String? detail) = switch (row.state) {
      CheckinState.pending => (Icons.cloud_queue_rounded, EvxTone.warning, l.statePending, null),
      CheckinState.confirmed => (Icons.cloud_done_rounded, EvxTone.success, l.badgeUploaded, l.checkedInAtTime(time)),
      CheckinState.conflict => (Icons.warning_amber_rounded, EvxTone.warning, l.badgeNotCounted, l.stateConflict(time)),
      CheckinState.rejected => (Icons.block_rounded, EvxTone.danger, l.badgeNotCounted, l.stateRejected(l.reasonRemoved)),
    };
    final color = switch (tone) {
      EvxTone.success => t.success,
      EvxTone.danger => t.danger,
      _ => t.warning,
    };
    return Material(
      color: row.seen ? Colors.transparent : t.warningBg,
      child: InkWell(
        onTap: row.seen ? null : () => ref.read(databaseProvider).markSeen(row.clientId),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(context.pick(row.guestNameEn, row.guestNameAr),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15)),
                  ),
                  Text(context.clock(row.scannedAt), style: Theme.of(context).textTheme.bodySmall),
                ]),
                const SizedBox(height: 5),
                EvxBadge(badge, tone: tone),
                if (detail != null) ...[
                  const SizedBox(height: 5),
                  Text(detail, style: Theme.of(context).textTheme.bodySmall),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
