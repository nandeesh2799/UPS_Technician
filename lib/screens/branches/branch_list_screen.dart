import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/center_model.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';
import 'widgets/add_edit_branch_sheet.dart';

class BranchListScreen extends StatelessWidget {
  const BranchListScreen({super.key});

  void _showAddEditSheet(BuildContext context, [CenterModel? branch]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditBranchSheet(branch: branch),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      body: Consumer<BranchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const ShimmerList();

          final branches = provider.branches;

          if (branches.isEmpty) {
            return const EmptyState(
              icon: Icons.business,
              title: 'No Branches Found',
              subtitle: 'Add service centers to manage multi-branch operations.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  onTap: () => _showAddEditSheet(context, branch),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.business, color: Theme.of(context).primaryColor),
                  ),
                  title: Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(branch.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'branch_list_fab',
        onPressed: () => _showAddEditSheet(context),
        icon: const Icon(Icons.add_business),
        label: const Text('Add Branch'),
      ),
    );
  }
}
