import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

import 'company_profile_screen.dart';
import 'invoice_settings_screen.dart';
import 'notification_prefs_screen.dart';
import '../../utils/logout_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;
    final user = authProvider.user;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final companyName = settingsProvider.settings.name;
    final logoUrl = settingsProvider.settings.logoUrl;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            _buildProfileCard(context, userModel, user, companyName, logoUrl),
            const SizedBox(height: 32),
            _buildSettingsGroup(context, 'Business', [
              _buildSettingsTile(
                context,
                icon: Icons.business_outlined,
                title: 'Company Profile',
                subtitle: 'Name, logo, UPI ID & contact details',
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyProfileScreen())),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Invoice Settings',
                subtitle: 'Payment and layout preferences',
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceSettingsScreen())),
              ),
            ]).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 24),
            _buildSettingsGroup(context, 'Preferences', [
              _buildSettingsTile(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Alerts and sound settings',
                color: Colors.red,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPrefsScreen())),
              ),
            ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 48),
            const Text(
              'UPS Service Manager v2.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const Text(
              'Powered by Karunadu Electronics',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? userModel, dynamic user, String companyName, String logoUrl) {
    final name = (userModel?.name.trim().isNotEmpty == true) 
        ? userModel!.name 
        : (user?.displayName?.trim().isNotEmpty == true ? user!.displayName! : companyName);
    final email = (userModel?.email.trim().isNotEmpty == true) 
        ? userModel!.email 
        : (user?.email?.trim().isNotEmpty == true ? user!.email! : 'admin@karunadu.com');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF9248)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
              image: logoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(logoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: logoUrl.isEmpty
                ? const Center(
                    child: Icon(Icons.storefront_outlined, color: Colors.white, size: 32),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    userModel?.role.toUpperCase() ?? 'PRO PLAN',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: tiles.asMap().entries.map((entry) {
              final idx = entry.key;
              final tile = entry.value;
              if (idx == tiles.length - 1) return tile;
              return Column(
                children: [
                  tile,
                  Divider(height: 1, indent: 64, endIndent: 20, color: Colors.grey.shade100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
        color: Colors.redAccent.withValues(alpha: 0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => LogoutHelper.logout(context),
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                SizedBox(width: 12),
                Text(
                  'Logout Account',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05, end: 0);
  }
}
