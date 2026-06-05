import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/logout_helper.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/orders/order_list_screen.dart';
import '../screens/inventory/parts_catalog_screen.dart';
import '../screens/financials/revenue_report_screen.dart';
import '../screens/technicians/technician_list_screen.dart';
import '../screens/branches/branch_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(32)),
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, const Color(0xFFFF9248)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.power, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  userModel?.name ?? 'UPS Service',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userModel?.role.toUpperCase() ?? 'Manager Pro',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _drawerItem(context, Icons.dashboard_outlined, 'Dashboard', const DashboardScreen()),
          _drawerItem(context, Icons.list_alt_outlined, 'Service Orders', const OrderListScreen()),
          
          if (userModel?.canManageInventory ?? true)
            _drawerItem(context, Icons.inventory_2_outlined, 'Inventory', const PartsCatalogScreen()),
          
          if (userModel?.canViewFinancials ?? false)
            _drawerItem(context, Icons.analytics_outlined, 'Financials', const RevenueReportScreen()),
          
          if (userModel?.canManageTechnicians ?? false)
            _drawerItem(context, Icons.engineering_outlined, 'Technicians', const TechnicianListScreen()),
          
          if (userModel?.isAdmin ?? false)
            _drawerItem(context, Icons.business_outlined, 'Branches', const BranchListScreen()),
          
          const Spacer(),
          const Divider(indent: 24, endIndent: 24),
          _drawerItem(context, Icons.settings_outlined, 'Settings', const SettingsScreen()),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => LogoutHelper.logout(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
        },
      ),
    );
  }
}
