import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/technician_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';
import 'technician_detail_screen.dart';
import 'widgets/add_edit_technician_sheet.dart';

class TechnicianListScreen extends StatelessWidget {
  const TechnicianListScreen({super.key});

  void _showAddEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditTechnicianSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.userModel?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Technicians')),
      body: Consumer<TechnicianProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const ShimmerList();

          final techs = provider.technicians;

          if (techs.isEmpty) {
            return const EmptyState(
              icon: Icons.engineering,
              title: 'No Technicians Found',
              subtitle: 'Add staff members to assign them orders.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: techs.length,
            itemBuilder: (context, index) {
              final tech = techs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TechnicianDetailScreen(technician: tech))),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.engineering, color: Theme.of(context).primaryColor),
                  ),
                  title: Text(tech.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${tech.role.toUpperCase()} • ${tech.phone}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: tech.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(tech.isActive ? 'Active' : 'Inactive', style: TextStyle(color: tech.isActive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        heroTag: 'tech_list_fab',
        onPressed: () => _showAddEditSheet(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Tech'),
      ) : null,
    );
  }
}
