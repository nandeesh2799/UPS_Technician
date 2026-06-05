import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'orders/order_list_screen.dart';
import 'financials/revenue_report_screen.dart';
import 'settings/settings_screen.dart';
import '../providers/auth_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;

    final List<Widget> screens = [
      const DashboardScreen(),
      const OrderListScreen(),
    ];

    if (userModel?.canViewFinancials ?? false) {
      screens.add(const RevenueReportScreen());
    }

    screens.add(const SettingsScreen());

    // Ensure _currentIndex is within bounds if role changes
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SalomonBottomBar(
          itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            /// Dashboard
            SalomonBottomBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              title: const Text("Dashboard"),
              selectedColor: Theme.of(context).primaryColor,
            ),

            /// Orders
            SalomonBottomBarItem(
              icon: const Icon(Icons.assignment_outlined),
              title: const Text("Orders"),
              selectedColor: Theme.of(context).primaryColor,
            ),

            /// Reports (only for admins)
            if (userModel?.canViewFinancials ?? false)
              SalomonBottomBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                title: const Text("Reports"),
                selectedColor: Theme.of(context).primaryColor,
              ),

            /// Profile
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline),
              title: const Text("Profile"),
              selectedColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
