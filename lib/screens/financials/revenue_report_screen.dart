import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/order_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/payment_model.dart';
import '../../models/order_model.dart';
import '../../utils/formatters.dart';
import '../../theme/app_colors.dart';
import '../dashboard/widgets/revenue_chart.dart';
import 'widgets/payment_mode_chart.dart';
import 'widgets/transaction_list.dart';
import '../../services/export_service.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  String _timeFilter = 'Monthly'; // 'Daily', 'Weekly', 'Monthly', 'Yearly'

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return orders.where((order) {
      final orderDate = order.serviceDate;
      if (_timeFilter == 'Daily') {
        return orderDate.year == today.year &&
               orderDate.month == today.month &&
               orderDate.day == today.day;
      } else if (_timeFilter == 'Weekly') {
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return orderDate.isAfter(sevenDaysAgo) || orderDate.isAtSameMomentAs(sevenDaysAgo);
      } else if (_timeFilter == 'Monthly') {
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        return orderDate.isAfter(thirtyDaysAgo) || orderDate.isAtSameMomentAs(thirtyDaysAgo);
      } else if (_timeFilter == 'Yearly') {
        final threeSixtyFiveDaysAgo = today.subtract(const Duration(days: 365));
        return orderDate.isAfter(threeSixtyFiveDaysAgo) || orderDate.isAtSameMomentAs(threeSixtyFiveDaysAgo);
      }
      return true;
    }).toList();
  }

  List<PaymentModel> _getFilteredPayments(List<PaymentModel> payments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return payments.where((p) {
      final date = p.date;
      if (_timeFilter == 'Daily') {
        return date.year == today.year &&
               date.month == today.month &&
               date.day == today.day;
      } else if (_timeFilter == 'Weekly') {
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return date.isAfter(sevenDaysAgo) || date.isAtSameMomentAs(sevenDaysAgo);
      } else if (_timeFilter == 'Monthly') {
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        return date.isAfter(thirtyDaysAgo) || date.isAtSameMomentAs(thirtyDaysAgo);
      } else if (_timeFilter == 'Yearly') {
        final threeSixtyFiveDaysAgo = today.subtract(const Duration(days: 365));
        return date.isAfter(threeSixtyFiveDaysAgo) || date.isAtSameMomentAs(threeSixtyFiveDaysAgo);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download, size: 20),
            onSelected: (value) {
              final provider = Provider.of<OrderProvider>(context, listen: false);
              if (value == 'excel') {
                ExportService.exportOrdersToExcel(provider.orders);
              } else if (value == 'tally') {
                ExportService.exportOrdersToTallyXml(provider.orders);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'excel', child: Text('Export to Excel')),
              const PopupMenuItem(value: 'tally', child: Text('Export to Tally XML')),
            ],
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final filteredOrders = _getFilteredOrders(provider.orders);
          final double filteredRevenue = filteredOrders.fold(0.0, (total, order) {
            final amountPaid = order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
            return total + amountPaid;
          });
          final double filteredDues = filteredOrders.where((o) => o.balanceAmount > 0).fold(0.0, (total, order) => total + order.balanceAmount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeFilter(),
                const SizedBox(height: 24),
                _buildHeaderStats(filteredRevenue, filteredDues),
                const SizedBox(height: 32),
                Text(
                  'Revenue Growth',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RevenueChart(timeframe: _timeFilter).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleStatCard(
                        context,
                        title: 'Avg. Order',
                        value: '₹${(filteredRevenue / (filteredOrders.isNotEmpty ? filteredOrders.length : 1)).toStringAsFixed(0)}',
                        icon: Icons.trending_up,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSimpleStatCard(
                        context,
                        title: 'Growth',
                        value: '+14.2%',
                        icon: Icons.bolt,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Payment Methods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                PaymentModeChart(orders: filteredOrders).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Filter')),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTransactionSection(context),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterChip('Daily'),
          _buildFilterChip('Weekly'),
          _buildFilterChip('Monthly'),
          _buildFilterChip('Yearly'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _timeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _timeFilter = label;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.dark : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStats(double revenue, double dues) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gross Revenue', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    Formatters.currency(revenue),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Dues', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    Formatters.currency(dues),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().slideY(begin: 0.2, end: 0);
  }

  Widget _buildSimpleStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          ),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(BuildContext context) {
    return StreamBuilder<List<PaymentModel>>(
      stream: FirebaseService().getPayments(),
      builder: (context, snapshot) {
        final payments = snapshot.data ?? [];
        final filteredPayments = _getFilteredPayments(payments);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: TransactionList(payments: filteredPayments),
        ).animate().fadeIn(delay: 600.ms);
      },
    );
  }
}
