import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/order_model.dart';

class StatusDonutChart extends StatelessWidget {
  final List<OrderModel> orders;

  const StatusDonutChart({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    int pending = orders.where((o) => o.status == 'Pending').length;
    int inProgress = orders.where((o) => o.status == 'In Progress' || o.status == 'Assigned').length;
    int completed = orders.where((o) => o.status == 'Completed').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                RepaintBoundary(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          color: Colors.orange,
                          value: pending.toDouble(),
                          title: pending > 0 ? '$pending' : '',
                          radius: 20,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.blue,
                          value: inProgress.toDouble(),
                          title: inProgress > 0 ? '$inProgress' : '',
                          radius: 20,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.green,
                          value: completed.toDouble(),
                          title: completed > 0 ? '$completed' : '',
                          radius: 20,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${orders.length}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const Text('Total Orders', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend(context, 'Pending', Colors.orange),
              _buildLegend(context, 'Active', Colors.blue),
              _buildLegend(context, 'Done', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
