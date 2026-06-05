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
import 'data_management_screen.dart';
import '../../utils/logout_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;
    final user = authProvider.user;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileCard(context, userModel, user),
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
              ]),
            const SizedBox(height: 24),
            _buildSettingsGroup(context, 'Preferences', [
              _buildSettingsTile(
                context,
                icon: settingsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                title: 'Dark Mode',
                subtitle: 'Switch application theme',
                color: Colors.indigo,
                trailing: Switch.adaptive(
                  value: settingsProvider.isDarkMode,
                  onChanged: (v) => settingsProvider.toggleTheme(),
                  activeTrackColor: AppColors.primary,
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Alerts and sound settings',
                color: Colors.red,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPrefsScreen())),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.storage_outlined,
                title: 'Data & Sync',
                subtitle: 'Backup and clear cache',
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataManagementScreen())),
              ),
            ]),
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

  Widget _buildProfileCard(BuildContext context, UserModel? userModel, dynamic user) {
    // Check if name and email are empty strings, fallback appropriately
    final name = (userModel?.name.trim().isNotEmpty == true) 
        ? userModel!.name 
        : (user?.displayName?.trim().isNotEmpty == true ? user!.displayName! : 'Admin Technician');
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
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
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
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: tiles,
            ),
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
    return ListTile(
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
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => LogoutHelper.logout(context),
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Logout Account'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}
