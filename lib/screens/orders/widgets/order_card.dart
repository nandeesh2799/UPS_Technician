import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/order_model.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../order_detail_screen.dart';
import 'status_chip.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isCompact;

  const OrderCard({super.key, required this.order, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)));
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.bolt, size: 12, color: AppColors.primary.withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${order.upsBrand} ${order.upsModel}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      StatusChip(status: order.status),
                    ],
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 12),
                    _buildMiniProgressTracker(context, order.status),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  Formatters.date(order.serviceDate),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              Formatters.currency(order.totalAmount),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.call_outlined,
                          color: Colors.blue, // Using a basic material color for call
                          onPressed: () => launchUrl(Uri.parse('tel:${order.phone}'), mode: LaunchMode.externalApplication),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context,
                          icon: Icons.chat_outlined,
                          color: Colors.green, // Using a basic material color for WhatsApp
                          onPressed: () => launchUrl(Uri.parse('whatsapp://send?phone=${order.phone}'), mode: LaunchMode.externalApplication),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context,
                          icon: Icons.directions_outlined,
                          color: Colors.indigo,
                          onPressed: () => launchUrl(
                            Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(order.address)}'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)));
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.outline,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Details',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }

  Widget _buildMiniProgressTracker(BuildContext context, String status) {
    int stepIndex = 0;
    if (status == 'Pending' || status == 'Assigned') {
      stepIndex = 0;
    } else if (status == 'In Progress' || status == 'Diagnosed' || status == 'Waiting for Parts') {
      stepIndex = 1;
    } else if (status == 'Completed') {
      stepIndex = 2;
    } else if (status == 'Delivered' || status == 'Picked Up') {
      stepIndex = 3;
    }

    final steps = ['Pending', 'Progress', 'Done', 'Delivered'];
    
    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index <= stepIndex;
            final isCurrent = index == stepIndex;
            final isLast = index == steps.length - 1;
            
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0
                          ? Colors.transparent
                          : (isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade200),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Theme.of(context).primaryColor : Colors.white,
                      border: Border.all(
                        color: isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade300,
                        width: isCurrent ? 3.5 : 1.5,
                      ),
                    ),
                    child: isCompleted && !isCurrent
                        ? const Center(child: Icon(Icons.check, size: 8, color: Colors.white))
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isLast
                          ? Colors.transparent
                          : (index < stepIndex ? Theme.of(context).primaryColor : Colors.grey.shade200),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isCompleted = index <= stepIndex;
            final isCurrent = index == stepIndex;
            return Expanded(
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent
                      ? Theme.of(context).primaryColor
                      : (isCompleted ? Colors.grey.shade700 : Colors.grey.shade400),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
