import 'package:flutter/material.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const BackButton(),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search orders, customers, parts...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _isSearching = false);
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isSearching = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildSmartSuggestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Smart Suggestions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _suggestionTile(Icons.warning, '3 Overdue Orders', Colors.red),
        _suggestionTile(Icons.security, '2 Warranties Expiring', Colors.orange),
        _suggestionTile(Icons.inventory_2, '5 Parts Low Stock', Colors.blue),
        const SizedBox(height: 32),
        Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const ListTile(leading: Icon(Icons.history), title: Text('Ramesh Kumar')),
        const ListTile(leading: Icon(Icons.history), title: Text('APC Logic Board')),
      ],
    );
  }

  Widget _suggestionTile(IconData icon, String title, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ListTile(title: Text('ORD-1001'), subtitle: Text('Ramesh Kumar - APC Back-UPS')),
        Divider(),
        Text('Customers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ListTile(title: Text('Ramesh Kumar'), subtitle: Text('+919876543210')),
      ],
    );
  }
}
