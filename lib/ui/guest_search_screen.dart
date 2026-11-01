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
      body = MessageView(icon: Icons.person_search, title: l.searchTooShort);
    } else if (_results == null || (_searching && _results!.isEmpty)) {
      body = const LoadingView();
    } else if (_results!.isEmpty) {
      body = MessageView(icon: Icons.search_off, title: l.searchNoMatch(q));
    } else {
      body = ListView.separated(
        itemCount: _results!.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final g = _results![i];
          final other = context.other(g.guest.nameEn, g.guest.nameAr);
          return ListTile(
            title: Text(context.pick(g.guest.nameEn, g.guest.nameAr)),
            subtitle: Text([
              ?other,
              if (g.guest.tableNumber != null) l.table(g.guest.tableNumber!),
            ].join(' · ')),
            trailing: g.checkedIn
                ? Chip(
                    label: Text(l.badgeIn),
                    avatar: const Icon(Icons.check, size: 16, color: Colors.white),
                    backgroundColor: EvxColors.success,
                    labelStyle: const TextStyle(color: Colors.white),
                  )
                : const Icon(Icons.login),
            onTap: () => _checkIn(g),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.searchByName)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            key: const Key('guest-search'),
            controller: _query,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.searchHint,
              prefixIcon: const Icon(Icons.search),
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
