import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/technician_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_counter.dart';
import 'widgets/add_edit_technician_sheet.dart';

class TechnicianDetailScreen extends StatelessWidget {
  final TechnicianModel technician;

  const TechnicianDetailScreen({super.key, required this.technician});

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditTechnicianSheet(technician: technician),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.userModel?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Profile'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditSheet(context),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.engineering, size: 40, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            Text(technician.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(technician.role.toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatCard(context, 'Orders Completed', technician.ordersCompleted, Icons.check_circle, Colors.green),
                const SizedBox(width: 16),
                _buildStatCard(context, 'Avg Rating', technician.avgRating, Icons.star, Colors.amber),
              ],
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Current Workload', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('No active orders assigned.', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, num value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            AnimatedCounter(count: value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
