import 'package:flutter/material.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  bool _warrantyAlerts = true;
  bool _overdueAlerts = true;
  bool _dailySummary = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Warranty Expiry Alerts'),
            subtitle: const Text('Notify 7 days before warranty expires'),
            value: _warrantyAlerts,
            onChanged: (v) => setState(() => _warrantyAlerts = v),
          ),
          SwitchListTile(
            title: const Text('Overdue Payment Alerts'),
            subtitle: const Text('Notify when payment is overdue by 3 days'),
            value: _overdueAlerts,
            onChanged: (v) => setState(() => _overdueAlerts = v),
          ),
          SwitchListTile(
            title: const Text('Daily Morning Summary'),
            subtitle: const Text('Receive a push notification at 9:00 AM with pending tasks'),
            value: _dailySummary,
            onChanged: (v) => setState(() => _dailySummary = v),
          ),
        ],
      ),
    );
  }
}
