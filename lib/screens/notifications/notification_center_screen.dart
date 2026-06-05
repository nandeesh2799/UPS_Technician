import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';
import '../../utils/formatters.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;

          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              subtitle: 'You are all caught up!',
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              IconData icon;
              Color color;

              switch (notif.type) {
                case 'warranty': icon = Icons.security; color = Colors.blue; break;
                case 'overdue': icon = Icons.warning; color = Colors.red; break;
                case 'payment': icon = Icons.payments; color = Colors.green; break;
                default: icon = Icons.info; color = Colors.grey; break;
              }

              return Dismissible(
                key: Key(notif.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => provider.deleteNotification(notif.id),
                child: ListTile(
                  onTap: () => provider.markAsRead(notif.id),
                  tileColor: notif.isRead ? null : color.withValues(alpha: 0.05),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(Formatters.dateTime(notif.timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
