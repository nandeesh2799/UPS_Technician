import 'package:flutter/material.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Export', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export all data to JSON'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export orders to CSV'),
            onTap: () {},
          ),
          const Divider(),
          const Text('Storage', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear local cache'),
            subtitle: const Text('Frees up device storage'),
            onTap: () {},
          ),
          const Divider(),
          const Text('Danger Zone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Factory Reset App', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Deletes all local data and logs out'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
