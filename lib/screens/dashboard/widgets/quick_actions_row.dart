import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../orders/order_wizard/order_wizard_screen.dart';
import '../../notifications/notification_center_screen.dart';
import '../../financials/revenue_report_screen.dart';
import '../../appointments/appointment_list_screen.dart';
import '../../inventory/parts_catalog_screen.dart';
import '../../technicians/technician_list_screen.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionItem(
            context,
            icon: Icons.add_task,
            label: 'New Order',
            color: AppColors.primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderWizardScreen())),
          ),
          _buildActionItem(
            context,
            icon: Icons.notifications_active_outlined,
            label: 'Reminder',
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationCenterScreen())),
          ),
          _buildActionItem(
            context,
            icon: Icons.analytics_outlined,
            label: 'Reports',
            color: Colors.indigo,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueReportScreen())),
          ),
          _buildActionItem(
            context,
            icon: Icons.calendar_month_outlined,
            label: 'Schedule',
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentListScreen())),
          ),
          _buildActionItem(
            context,
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            color: Colors.blueGrey,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartsCatalogScreen())),
          ),
          _buildActionItem(
            context,
            icon: Icons.engineering_outlined,
            label: 'Techs',
            color: Colors.brown,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianListScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2, end: 0);
  }
}
