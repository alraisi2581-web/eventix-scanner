import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'common.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _showPassword = false;
  Object? _error;
  List<({String username, int count})> _waiting = const [];

  @override
  void initState() {
    super.initState();
    ref.read(lastUsernameProvider.future).then((name) {
      if (mounted && name != null && _username.text.isEmpty) {
        _username.text = name;
      }
    });
    // check-ins made before a sign-out or an expired sign-in, still to upload
    ref.read(databaseProvider).pendingByOtherUsers(-1).then((w) {
      if (mounted) setState(() => _waiting = w);
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .signIn(_username.text.trim(), _password.text);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          LanguageButton(
              onSelected: (c) => ref.read(languageProvider.notifier).set(c)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.qr_code_scanner,
                          size: 72, color: EvxColors.navy),
                      const SizedBox(height: 12),
                      Text(l.signInTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(l.signInHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      for (final w in _waiting)
                        Card(
                          color: const Color(0xFFFDF5E6),
                          child: ListTile(
                            leading: const Icon(Icons.cloud_upload_outlined,
                                color: EvxColors.warning),
                            title: Text(l.pendingFromBefore(w.count, w.username)),
                          ),
                        ),
                      TextFormField(
                        controller: _username,
                        decoration: InputDecoration(
                          labelText: l.username,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        autofillHints: const [AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        enabled: !_busy,
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return l.usernameRequired;
                          if (t.length > 100) return l.usernameTooLong;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        decoration: InputDecoration(
                          labelText: l.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _showPassword ? l.hidePassword : l.showPassword,
                            icon: Icon(_showPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        obscureText: !_showPassword,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        enabled: !_busy,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) =>
                            (v ?? '').isEmpty ? l.passwordRequired : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          apiErrorText(l, _error!),
                          key: const Key('login-error'),
                          style: const TextStyle(color: EvxColors.danger),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : Text(l.signIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
