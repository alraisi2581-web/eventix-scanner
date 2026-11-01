import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/eventix_api.dart';
import '../data/db/database.dart';
import '../providers.dart';
import 'common.dart';
import 'scan_screen.dart';

/// The events this scanner may check guests in for. Shows the copy saved on
/// the phone at once and refreshes it from the server when online.
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  bool _refreshing = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      await refreshEvents(ref);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _open(EventRow event) async {
    final l = context.l10n;
    if (event.listDownloadedAt == null) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(l.downloadingList)),
          ]),
        ),
      );
      Object? failure;
      try {
        await downloadGuestList(ref, event.id);
      } catch (e) {
        failure = e;
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      if (failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(failure is NetworkException
              ? l.downloadNeedsNetwork
              : apiErrorText(l, failure)),
        ));
        return;
      }
    }
    if (!mounted) return;
    await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ScanScreen(eventId: event.id)));
  }

  Future<void> _signOut() async {
    final l = context.l10n;
    final pending = ref.read(pendingCountProvider).valueOrNull ?? 0;
    if (pending > 0) {
      final go = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l.signOutPendingTitle),
          content: Text(l.signOutPendingBody(pending)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(c, true), child: Text(l.signOut)),
          ],
        ),
      );
      if (go != true) return;
    }
    await ref.read(authProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final events = ref.watch(eventsProvider);
    final session = ref.watch(authProvider).valueOrNull;
    ref.watch(syncProvider); // keeps uploads running while signed in

    final list = events.valueOrNull ?? const <EventRow>[];
    Widget body;
    if (list.isEmpty && (_refreshing || events.isLoading)) {
      body = const LoadingView();
    } else if (list.isEmpty && _error != null) {
      body = ErrorView(message: apiErrorText(l, _error!), onRetry: _refresh);
    } else if (list.isEmpty) {
      body = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .7,
            child: MessageView(
                icon: Icons.event_busy,
                title: l.noEventsTitle,
                body: l.noEventsBody),
          ),
        ]),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            if (_error != null)
              MaterialBanner(
                leading: const Icon(Icons.cloud_off, color: EvxColors.warning),
                content: Text(_error is NetworkException
                    ? l.offlineSavedList
                    : apiErrorText(l, _error!)),
                actions: [TextButton(onPressed: _refresh, child: Text(l.retry))],
              ),
            for (final e in list) _EventTile(event: e, onTap: () => _open(e)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.yourEvents),
        actions: [
          LanguageButton(
              onSelected: (c) => ref.read(languageProvider.notifier).set(c)),
          IconButton(
            tooltip: l.signOut,
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
        bottom: session == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(l.signedInAs(session.username),
                      style: const TextStyle(color: Colors.white70)),
                ),
              ),
      ),
      body: body,
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onTap});
  final EventRow event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final saved = event.listDownloadedAt != null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(context.pick(event.titleEn, event.titleAr),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(event.startsLabel),
            Text(context.pick(event.venueEn, event.venueAr)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(saved ? Icons.offline_pin : Icons.cloud_download_outlined,
                  size: 16,
                  color: saved ? EvxColors.success : EvxColors.warning),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${l.guestCount(event.guestCount)} · ${saved ? l.listSaved : l.listNotSaved}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ]),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
