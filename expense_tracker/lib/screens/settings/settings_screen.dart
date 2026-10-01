import 'package:expense_tracker/providers/auth_provider.dart' as app_auth;
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final expenseProvider = context.watch<ExpenseProvider>();
    final authProvider = context.read<app_auth.AuthProvider>();

    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor =
        isDark ? const Color(0xFF888888) : const Color(0xFF999999);

    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'User';
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Profile',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // ── Avatar + name card ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: subColor, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Menu items ─────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  iconColor: const Color(0xFF2196F3),
                  title: 'Edit Profile',
                  onTap: () => _showEditNameDialog(context, user),
                  isDark: isDark,
                  textColor: textColor,
                ),
                _Divider(isDark: isDark),
                _MenuItem(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_outlined,
                  iconColor: const Color(0xFFFF9800),
                  title: 'Dark Mode',
                  trailing: Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: isDark,
                      onChanged: (_) => expenseProvider.toggleTheme(),
                      activeThumbColor: AppTheme.accentGreen,
                      activeTrackColor:
                          AppTheme.accentGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  isDark: isDark,
                  textColor: textColor,
                ),
                _Divider(isDark: isDark),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'Privacy Policy',
                  onTap: () {},
                  isDark: isDark,
                  textColor: textColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Logout ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _MenuItem(
              icon: Icons.logout_rounded,
              iconColor: AppTheme.expenseRed,
              title: 'Logout',
              titleColor: AppTheme.expenseRed,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor:
                        isDark ? AppTheme.darkCard : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Text('Sign Out',
                        style: TextStyle(color: textColor)),
                    content: Text(
                        'Are you sure you want to sign out?',
                        style: TextStyle(color: subColor)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel',
                            style: TextStyle(color: subColor)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out',
                            style:
                                TextStyle(color: AppTheme.expenseRed)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  context.read<ExpenseProvider>().reset();
                  await authProvider.signOut();
                }
              },
              isDark: isDark,
              textColor: textColor,
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text('Version 1.0.0',
                style: TextStyle(fontSize: 12, color: subColor)),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, User? user) {
    final controller =
        TextEditingController(text: user?.displayName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await user?.updateDisplayName(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;
  final Color textColor;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.trailing,
    this.onTap,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right,
                        color: isDark
                            ? const Color(0xFF555555)
                            : const Color(0xFFCCCCCC),
                        size: 22)
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 0,
      color:
          isDark ? AppTheme.darkBorder : Colors.grey.shade100,
    );
  }
}
