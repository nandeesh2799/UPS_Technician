import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_boundary.dart';
import 'widgets/order_card.dart';
import 'order_wizard/order_wizard_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<OrderProvider>().fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Service Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search orders, customers...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Pending', 'In Progress', 'Completed', 'Delivered'].map((status) {
                final isSelected = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _statusFilter = status);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : Colors.grey.shade200),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const ShimmerList();
                if (provider.error != null) return CompactErrorWidget(message: provider.error!);

                var filteredOrders = provider.orders.where((o) {
                  bool matchesSearch = o.customerName.toLowerCase().contains(_searchQuery) ||
                                       o.id.toLowerCase().contains(_searchQuery) ||
                                       o.phone.contains(_searchQuery);
                  bool matchesFilter = _statusFilter == 'All' || o.status == _statusFilter;
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inbox,
                    title: 'No Orders Found',
                    subtitle: 'Try adjusting your search or filters.',
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  cacheExtent: MediaQuery.of(context).size.height * 2,
                  itemCount: filteredOrders.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredOrders.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return OrderCard(order: filteredOrders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'order_list_fab',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderWizardScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
}
