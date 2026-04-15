import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/storage/local_storage.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/theme_cubit.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/block/auth_event.dart';
import 'package:votera_app/features/user/domain/repositories/iuser_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final LocalStorageService _prefs;
  late bool _notificationsEnabled;
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    _prefs = sl<LocalStorageService>();
    _notificationsEnabled = _prefs.notificationsEnabled;
  }

  // ── Helpers ────────────────────────────────────────────────

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System default',
  };

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };

  // ── Theme picker ───────────────────────────────────────────

  void _showThemePicker(BuildContext context, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.metallicBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose Theme',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final mode in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: current,
                  activeColor: AppColors.blue,
                  title: Text(_themeName(mode)),
                  secondary: Icon(_themeIcon(mode)),
                  onChanged: (selected) {
                    if (selected != null) {
                      context.read<ThemeCubit>().setMode(selected);
                    }
                    Navigator.pop(sheetCtx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Delete account ─────────────────────────────────────────

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingAccount = true);
    try {
      final message = await sl<IUserRepository>().deleteAccount();
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Account Deleted'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      await _prefs.clearCache();
      context.read<AuthBloc>().add(const LogoutRequested());
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.login, (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ── Legal dialogs ──────────────────────────────────────────

  void _showLegal(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              body,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _deletingAccount
          ? const Center(child: CircularProgressIndicator())
          : BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return ListView(
                  children: [
                    // ── APPEARANCE ───────────────────────────
                    _SectionHeader('APPEARANCE'),
                    _SettingsTile(
                      icon: _themeIcon(themeMode),
                      iconColor: AppColors.blue,
                      title: 'Theme',
                      subtitle: _themeName(themeMode),
                      onTap: () => _showThemePicker(context, themeMode),
                    ),

                    // ── NOTIFICATIONS ────────────────────────
                    _SectionHeader('NOTIFICATIONS'),
                    _SettingsToggleTile(
                      icon: Icons.notifications_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts for polls and updates',
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                        _prefs.notificationsEnabled = val;
                      },
                    ),

                    // ── ACCOUNT ──────────────────────────────
                    _SectionHeader('ACCOUNT'),
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Edit Profile',
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.profile),
                    ),
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      iconColor: AppColors.error,
                      title: 'Delete Account',
                      subtitle: 'Permanently remove your account',
                      titleColor: AppColors.error,
                      onTap: () => _confirmDeleteAccount(),
                    ),

                    // ── LEGAL ────────────────────────────────
                    _SectionHeader('LEGAL'),
                    _SettingsTile(
                      icon: Icons.article_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Terms of Service',
                      onTap: () =>
                          _showLegal(context, 'Terms of Service', _kTerms),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Privacy Policy',
                      onTap: () =>
                          _showLegal(context, 'Privacy Policy', _kPrivacy),
                    ),

                    // ── ABOUT ────────────────────────────────
                    _SectionHeader('ABOUT'),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.info,
                      title: 'App Version',
                      trailing: const Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.star_outline_rounded,
                      iconColor: AppColors.gold,
                      title: 'Rate Votera',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening store… (coming soon)'),
                          ),
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.mail_outline_rounded,
                      iconColor: AppColors.info,
                      title: 'Contact Us',
                      subtitle: 'support@votera.app',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening email… (coming soon)'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

// ── Settings Tile ───────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.iconColor = AppColors.blue,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                )
              : null),
      onTap: onTap,
    );
  }
}

// ── Settings Toggle Tile ────────────────────────────────────────────────────────

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.blue,
      ),
      onTap: () => onChanged(!value),
    );
  }
}

// ── Legal copy ──────────────────────────────────────────────────────────────────

const _kTerms = '''
Welcome to Votera. By using this application, you agree to the following terms and conditions.

1. ACCEPTANCE OF TERMS
By accessing or using Votera, you confirm that you are at least 18 years of age and agree to be bound by these Terms of Service.

2. USE OF SERVICE
You may use Votera solely for lawful purposes. You agree not to misuse the platform, including but not limited to: submitting false information, manipulating poll results, or engaging in any fraudulent activity.

3. ACCOUNT RESPONSIBILITY
You are responsible for maintaining the confidentiality of your account credentials. Any activity that occurs under your account is your responsibility.

4. INTELLECTUAL PROPERTY
All content, branding, and features of Votera are the intellectual property of Votera and its licensors.

5. TERMINATION
We reserve the right to suspend or terminate your account at any time if you violate these terms.

6. CHANGES TO TERMS
We may update these Terms of Service at any time. Continued use of the app after changes constitutes acceptance.

For questions, contact support@votera.app.
''';

const _kPrivacy = '''
Votera ("we", "our", "us") is committed to protecting your privacy.

1. DATA WE COLLECT
We collect information you provide directly, such as your name, mobile number, and email address during registration or profile updates.

2. HOW WE USE YOUR DATA
Your data is used to:
- Authenticate and manage your account
- Enable participation in polls and workspaces
- Send relevant notifications (if enabled)
- Improve the app experience

3. DATA SHARING
We do not sell your personal data. We may share data with trusted service providers who assist in operating the platform, subject to confidentiality obligations.

4. DATA RETENTION
We retain your data as long as your account is active. You may request deletion at any time via Settings > Delete Account.

5. SECURITY
We implement industry-standard security measures to protect your data, including encrypted storage and secure transmission.

6. YOUR RIGHTS
You have the right to access, correct, or delete your personal data at any time.

7. CONTACT
For privacy-related inquiries, contact: privacy@votera.app
''';
