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
            ? MessageView(icon: Icons.history, title: l.activityEmpty, body: l.undoHint)
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(syncProvider.notifier).syncNow(refreshList: true),
                child: ListView.separated(
                  itemCount: list.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => i == list.length
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(l.undoHint, textAlign: TextAlign.center),
                        )
                      : _Row(row: list[i]),
                ),
              ),
      ),
      floatingActionButton: pending == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: sync.syncing
                  ? null
                  : () => ref.read(syncProvider.notifier).kick(refreshList: true),
              icon: const Icon(Icons.cloud_upload),
              label: Text(l.uploadNow),
            ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.row});
  final CheckinRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final time = row.serverLabel ?? l.earlierTime;
    final (IconData icon, Color color, String text) = switch (row.state) {
      CheckinState.pending => (Icons.cloud_queue, EvxColors.warning, l.statePending),
      CheckinState.confirmed => (Icons.cloud_done, EvxColors.success, l.stateConfirmed(time)),
      CheckinState.conflict => (Icons.warning_amber, EvxColors.warning, l.stateConflict(time)),
      CheckinState.rejected => (Icons.block, EvxColors.danger, l.stateRejected(l.reasonRemoved)),
    };
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(context.pick(row.guestNameEn, row.guestNameAr)),
      subtitle: Text('${context.clock(row.scannedAt)} · $text'),
      tileColor: row.seen ? null : const Color(0xFFFDF5E6),
      onTap: row.seen ? null : () => ref.read(databaseProvider).markSeen(row.clientId),
    );
  }
}
