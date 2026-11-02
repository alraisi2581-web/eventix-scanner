import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../providers.dart';
import 'common.dart';

/// Check-in by name or table number, for a guest without their QR or when the
/// camera can't be used. Searches the list saved on the phone (works offline).
/// Returns the check-in outcome to the scan screen, which shows it.
class GuestSearchScreen extends ConsumerStatefulWidget {
  const GuestSearchScreen({super.key, required this.eventId});
  final int eventId;
  @override
  ConsumerState<GuestSearchScreen> createState() => _GuestSearchScreenState();
}

class _GuestSearchScreenState extends ConsumerState<GuestSearchScreen> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<GuestAtDoor>? _results; // null: nothing searched yet
  bool _searching = false;

  static final _tableNumber = RegExp(r'^\d{1,4}$');

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  /// At least 2 characters, or a table number ("7").
  bool get _valid {
    final q = _query.text.trim();
    return q.length >= 2 || _tableNumber.hasMatch(q);
  }

  void _changed(String _) {
    _debounce?.cancel();
    if (!_valid) {
      setState(() => _results = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), _search);
  }

  Future<void> _search() async {
    setState(() => _searching = true);
    final found = await ref
        .read(databaseProvider)
        .searchGuests(widget.eventId, _query.text.trim());
    if (!mounted) return;
    setState(() {
      _results = found;
      _searching = false;
    });
  }

  Future<void> _checkIn(GuestAtDoor g) async {
    final l = context.l10n;
    final name = context.pick(g.guest.nameEn, g.guest.nameAr);
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.checkInConfirm(name)),
        content: g.guest.tableNumber == null ? null : Text(l.table(g.guest.tableNumber!)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.checkIn),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final session = await ref.read(authProvider.future);
    if (session == null || !mounted) return;
    // read the guest again: the list may have been refreshed meanwhile
    final fresh = await ref.read(databaseProvider).guestById(g.guest.id) ?? g.guest;
    final outcome = await ref.read(checkinServiceProvider).checkIn(session, fresh);
    if (mounted) Navigator.of(context).pop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = _query.text.trim();
    Widget body;
    if (!_valid) {
      body = MessageView(icon: Icons.person_search_rounded, title: l.searchTooShort);
    } else if (_results == null || (_searching && _results!.isEmpty)) {
      body = const LoadingView();
    } else if (_results!.isEmpty) {
      body = MessageView(
          icon: Icons.search_off_rounded, tone: EvxTone.neutral, title: l.searchNoMatch(q));
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          EvxCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (final (i, g) in _results!.indexed) ...[
                if (i > 0) const Divider(height: 1),
                _GuestRow(guest: g, onTap: () => _checkIn(g)),
              ],
            ]),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.searchByName)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: TextField(
            key: const Key('guest-search'),
            controller: _query,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              counterText: '',
              errorText: q.isNotEmpty && !_valid ? l.searchTooShort : null,
            ),
            maxLength: 60,
            onChanged: _changed,
            onSubmitted: (_) => _valid ? _search() : null,
          ),
        ),
        Expanded(child: body),
      ]),
    );
  }
}

/// One guest in the results: name in both languages, table, RSVP and whether
/// they are in — the web guest table's columns as a row.
class _GuestRow extends StatelessWidget {
  const _GuestRow({required this.guest, required this.onTap});
  final GuestAtDoor guest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.evx;
    final g = guest.guest;
    final other = context.other(g.nameEn, g.nameAr);
    final rsvp = switch (g.rsvp) {
      'Not Attending' => (l.rsvpNotAttending, EvxTone.danger),
      'No Reply' => (l.rsvpNoReply, EvxTone.neutral),
      'Maybe' => (l.rsvpMaybe, EvxTone.warning),
      _ => null,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: guest.checkedIn ? t.successBg : t.goldBg,
            child: guest.checkedIn
                ? Icon(Icons.check_rounded, color: t.success)
                : Text(
                    context.pick(g.nameEn, g.nameAr).characters.first.toUpperCase(),
                    style: evxDisplay(17, color: t.gold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.pick(g.nameEn, g.nameAr),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15.5)),
              if (other != null)
                Text(other, style: Theme.of(context).textTheme.bodySmall),
              if (g.tableNumber != null || rsvp != null) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (g.tableNumber != null)
                    EvxBadge(l.table(g.tableNumber!), icon: Icons.table_restaurant_outlined),
                  if (rsvp != null) EvxBadge(rsvp.$1, tone: rsvp.$2),
                ]),
              ],
            ]),
          ),
          const SizedBox(width: 8),
          guest.checkedIn
              ? EvxBadge(l.badgeIn, tone: EvxTone.success, icon: Icons.check_rounded)
              : Icon(Icons.login_rounded, color: t.gold),
        ]),
      ),
    );
  }
}
