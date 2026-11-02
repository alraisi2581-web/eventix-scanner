import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/eventix_api.dart';
import '../data/db/database.dart';
import '../providers.dart';
import 'common.dart';
import 'scan_screen.dart';

/// The events this scanner may check guests in for — the web scanner
/// dashboard's cards. Shows the copy saved on the phone at once and refreshes
/// it from the server when online.
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
            SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: context.evx.gold)),
            const SizedBox(width: 18),
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
                onPressed: () => Navigator.pop(c, true),
                style: TextButton.styleFrom(foregroundColor: context.evx.danger),
                child: Text(l.signOut)),
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
    final header = PageHeader(
      title: l.yourEvents,
      subtitle: session == null ? null : l.signedInAs(session.username),
    );

    Widget body;
    if (list.isEmpty && (_refreshing || events.isLoading)) {
      body = const LoadingView();
    } else if (list.isEmpty && _error != null) {
      body = ErrorView(message: apiErrorText(l, _error!), onRetry: _refresh);
    } else if (list.isEmpty) {
      body = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(children: [
          header,
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .6,
            child: MessageView(
                icon: Icons.event_busy_rounded,
                title: l.noEventsTitle,
                body: l.noEventsBody),
          ),
        ]),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            header,
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: EvxAlert(
                  icon: Icons.cloud_off_rounded,
                  text: _error is NetworkException
                      ? l.offlineSavedList
                      : apiErrorText(l, _error!),
                  action: TextButton(onPressed: _refresh, child: Text(l.retry)),
                ),
              ),
            for (final e in list)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _EventCard(event: e, onOpen: () => _open(e)),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // the web's top bar: navy, the wordmark in white at 85%
        title: const Opacity(
            opacity: .9, child: EvxLogo(height: 22, color: Colors.white)),
        actions: [
          LanguageToggle(
              onDark: true,
              onSelected: (c) => ref.read(languageProvider.notifier).set(c)),
          const SizedBox(width: 6),
          ThemeToggle(
              onDark: true,
              onToggle: () => ref
                  .read(themeModeProvider.notifier)
                  .toggle(Theme.of(context).brightness)),
          IconButton(
            tooltip: l.signOut,
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: body,
    );
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event, required this.onOpen});
  final EventRow event;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.evx;
    final theme = Theme.of(context);
    final saved = event.listDownloadedAt != null;
    // the phone's own count once the list is saved (includes check-ins not yet uploaded)
    final counts = saved ? ref.watch(countsProvider(event.id)).valueOrNull : null;
    final total = counts?.total ?? event.guestCount;
    final inside = counts?.checkedIn ?? event.checkedInCount;
    final pct = total == 0 ? 0 : (inside * 100 / total).round();
    final other = context.other(event.titleEn, event.titleAr);

    return EvxCard(
      onTap: onOpen,
      footer: Row(children: [
        Icon(saved ? Icons.offline_pin_rounded : Icons.cloud_download_outlined,
            size: 18, color: saved ? t.success : t.warning),
        const SizedBox(width: 6),
        Expanded(child: Text(saved ? l.listSaved : l.listNotSaved)),
        Text(l.openScanner,
            style: theme.textTheme.labelLarge!.copyWith(color: t.gold, fontSize: 14)),
        Icon(Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: t.gold, size: 20),
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.pick(event.titleEn, event.titleAr),
            style: evxDisplay(20, color: t.text)),
        if (other != null) ...[
          const SizedBox(height: 2),
          Text(other,
              style: theme.textTheme.bodySmall!.copyWith(color: t.text2, fontSize: 14)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.schedule_rounded, size: 16, color: t.text3),
          const SizedBox(width: 6),
          Flexible(child: Text(event.startsLabel, style: theme.textTheme.bodySmall)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.place_outlined, size: 16, color: t.text3),
          const SizedBox(width: 6),
          Flexible(
              child: Text(context.pick(event.venueEn, event.venueAr),
                  style: theme.textTheme.bodySmall)),
        ]),
        const SizedBox(height: 16),
        EvxProgress(value: total == 0 ? 0 : inside / total),
        const SizedBox(height: 8),
        Text(l.eventProgress(inside, total, pct),
            style: theme.textTheme.bodySmall!.copyWith(color: t.text2)),
      ]),
    );
  }
}
