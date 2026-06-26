import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../orders/order_wizard/order_wizard_screen.dart';
import '../orders/order_list_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../../widgets/sync_status_widget.dart';
import 'widgets/kpi_card.dart';
import 'widgets/revenue_chart.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/recent_orders_row.dart';
import 'widgets/today_appointments_row.dart';
import 'widgets/low_stock_warning.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Streams in providers automatically update, but we can nudge them
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            const _DashboardHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RevenueCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const _StatsGrid(),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const QuickActionsRow(),
                    const SizedBox(height: 24),
                    const LowStockWarning(),
                    const TodayAppointmentsRow(),
                    const SizedBox(height: 24),
                    const RevenueChart(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Orders'.toUpperCase(),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                                letterSpacing: 1.2,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latest service requests',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen())),
                          child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _RecentOrdersSection(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderWizardScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: 1000.ms, curve: Curves.elasticOut),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 80.0,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Selector<AuthProvider, String?>(
                selector: (_, auth) {
                  final name = auth.userModel?.name ?? auth.user?.displayName;
                  return (name == null || name.trim().isEmpty) ? 'Technician' : name;
                },
                builder: (context, displayName, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                      ),
                      Text(
                        displayName ?? 'Technician',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SyncStatusWidget(),
            const SizedBox(width: 8),
            Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationCenterScreen())),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications_outlined, color: AppColors.primary, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final totalRevenue = provider.totalRevenue;
        final trendText = provider.monthlyPerformancePercentage;
        final trendUp = provider.isRevenueTrendUp;

        IconData trendIcon = Icons.trending_flat;
        if (trendUp == true) {
          trendIcon = Icons.trending_up;
        } else if (trendUp == false) {
          trendIcon = Icons.trending_down;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFF9248)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Monthly Performance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Total Revenue',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '₹${totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(trendIcon, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trendText,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            KpiCard(
              title: 'Total Orders',
              value: provider.orders.length,
              icon: Icons.assignment,
              color: AppColors.secondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderListScreen(initialStatusFilter: 'All'),
                ),
              ),
            ),
            KpiCard(
              title: 'Pending',
              value: provider.pendingOrders.length,
              icon: Icons.timer_outlined,
              color: AppColors.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderListScreen(initialStatusFilter: 'Pending'),
                ),
              ),
            ),
            KpiCard(
              title: 'In Progress',
              value: provider.inProgressOrders.length,
              icon: Icons.sync,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderListScreen(initialStatusFilter: 'In Progress'),
                ),
              ),
            ),
            KpiCard(
              title: 'Completed',
              value: provider.completedOrders.length,
              icon: Icons.check_circle_outline,
              color: AppColors.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderListScreen(initialStatusFilter: 'Completed'),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  const _RecentOrdersSection();

  @override
  Widget build(BuildContext context) {
    return Selector<OrderProvider, List>(
      selector: (_, provider) => provider.orders,
      builder: (context, orders, _) {
        return RecentOrdersRow(orders: orders.cast());
      },
    );
  }
}

