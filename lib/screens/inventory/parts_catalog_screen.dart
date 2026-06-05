import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parts_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';
import 'widgets/part_card.dart';
import '../../models/part_model.dart';
import '../../utils/extensions.dart';

class PartsCatalogScreen extends StatefulWidget {
  const PartsCatalogScreen({super.key});

  @override
  State<PartsCatalogScreen> createState() => _PartsCatalogScreenState();
}

class _PartsCatalogScreenState extends State<PartsCatalogScreen> {
  String _searchQuery = '';
  String _categoryFilter = 'All';

  final List<String> _categories = ['All', 'Batteries', 'Circuits', 'Connectors', 'Cables', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parts Catalog'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by part name or PN...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _categoryFilter == cat,
                    onSelected: (_) => setState(() => _categoryFilter = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<PartsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const ShimmerList();

                var filtered = provider.parts.where((p) {
                  bool matchesSearch = p.name.toLowerCase().contains(_searchQuery) || p.partNumber.toLowerCase().contains(_searchQuery);
                  bool matchesCat = _categoryFilter == 'All' || p.category == _categoryFilter;
                  return matchesSearch && matchesCat;
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(icon: Icons.inventory_2, title: 'No Parts Found', subtitle: 'Try adjusting your search or add a new part.');
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final part = filtered[index];
                    return PartCard(
                      part: part,
                      onTap: () => _showPartDialog(part: part),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'parts_catalog_fab',
        onPressed: () => _showPartDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Part'),
      ),
    );
  }

  void _showPartDialog({PartModel? part}) {
    final nameController = TextEditingController(text: part?.name);
    final pnController = TextEditingController(text: part?.partNumber);
    final priceController = TextEditingController(text: part?.sellingPrice.toString() ?? '0');
    final stockController = TextEditingController(text: part?.stockQty.toString() ?? '0');
    String category = part?.category ?? 'Other';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(part == null ? 'Add Part' : 'Edit Part'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Part Name')),
                TextField(controller: pnController, decoration: const InputDecoration(labelText: 'Part Number')),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock Quantity'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newPart = PartModel(
                  id: part?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  partNumber: pnController.text.trim(),
                  category: category,
                  costPrice: part?.costPrice ?? 0,
                  sellingPrice: double.tryParse(priceController.text) ?? 0,
                  stockQty: int.tryParse(stockController.text) ?? 0,
                );
                try {
                  if (part == null) {
                    await context.read<PartsProvider>().addPart(newPart);
                  } else {
                    await context.read<PartsProvider>().updatePart(newPart);
                  }
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) context.showErrorSnackBar('Failed to save part');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
