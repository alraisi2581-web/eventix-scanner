import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'common.dart';

/// The web's sign-in card (login.php, .evx-login-card): language switch and
/// theme button on top, the Eventix logo, labelled fields, navy button, footer.
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
    FocusScope.of(context).unfocus();
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
    final t = context.evx;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(text,
              style: theme.textTheme.labelMedium!
                  .copyWith(color: t.text2, fontSize: 13.5)),
        );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(radiusXl),
                  border: Border.all(color: t.border),
                  boxShadow: t.shadowLg,
                ),
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
                child: Form(
                  key: _form,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          LanguageToggle(
                              onSelected: (c) =>
                                  ref.read(languageProvider.notifier).set(c)),
                          const Spacer(),
                          ThemeToggle(
                              onToggle: () => ref
                                  .read(themeModeProvider.notifier)
                                  .toggle(theme.brightness)),
                        ]),
                        const SizedBox(height: 26),
                        Center(
                          child: EvxLogo(
                              height: 34,
                              color: dark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 14),
                        Text(l.signInTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: t.text3, fontSize: 14)),
                        const SizedBox(height: 26),
                        for (final w in _waiting) ...[
                          EvxAlert(
                            text: l.pendingFromBefore(w.count, w.username),
                            icon: Icons.cloud_upload_outlined,
                          ),
                          const SizedBox(height: 16),
                        ],
                        label(l.username),
                        TextFormField(
                          controller: _username,
                          autofillHints: const [AutofillHints.username],
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          enabled: !_busy,
                          style: theme.textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return l.usernameRequired;
                            if (s.length > 100) return l.usernameTooLong;
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        label(l.password),
                        TextFormField(
                          controller: _password,
                          obscureText: !_showPassword,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          enabled: !_busy,
                          style: theme.textTheme.bodyLarge,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _showPassword ? l.hidePassword : l.showPassword,
                              icon: Icon(_showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          validator: (v) =>
                              (v ?? '').isEmpty ? l.passwordRequired : null,
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: _error == null
                              ? const SizedBox(height: 26)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: EvxAlert(
                                    key: const Key('login-error'),
                                    text: apiErrorText(l, _error!),
                                    tone: EvxTone.danger,
                                    icon: Icons.error_outline_rounded,
                                  ),
                                ),
                        ),
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
                        const SizedBox(height: 22),
                        Text('${l.footer} © ${DateTime.now().year}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: t.text3, fontSize: 12.5)),
                      ],
                    ),
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
