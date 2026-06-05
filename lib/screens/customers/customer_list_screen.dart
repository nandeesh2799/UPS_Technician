import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_boundary.dart';
import 'widgets/customer_card.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _searchQuery = '';
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
      context.read<CustomerProvider>().fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const ShimmerList();
                if (provider.error != null) return CompactErrorWidget(message: provider.error!);

                var filtered = provider.customers.where((c) {
                  return c.name.toLowerCase().contains(_searchQuery) || c.phone.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(icon: Icons.people, title: 'No Customers Found', subtitle: 'Add a new customer to get started.');
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  cacheExtent: MediaQuery.of(context).size.height * 2,
                  itemCount: filtered.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filtered.length) {
                      return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                    }
                    return CustomerCard(customer: filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
