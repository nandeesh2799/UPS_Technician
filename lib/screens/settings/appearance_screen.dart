import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: provider.isDarkMode,
                  onChanged: (value) => provider.toggleTheme(),
                ),
              ),
              const Divider(),
              const ListTile(
                title: Text('Primary Color'),
                subtitle: Text('Deep Indigo (Default)'),
                // Could implement color picker here
              ),
            ],
          );
        },
      ),
    );
  }
}
