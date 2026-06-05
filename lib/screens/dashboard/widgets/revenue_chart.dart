import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/order_provider.dart';

class RevenueChart extends StatelessWidget {
  final String timeframe;
  const RevenueChart({super.key, this.timeframe = 'Monthly'});

  String _formatAmount(double value) {
    if (value >= 1000000) {
      double val = value / 1000000;
      return '${val.toStringAsFixed(val % 1 == 0 ? 0 : 1)}M';
    } else if (value >= 1000) {
      double val = value / 1000;
      return '${val.toStringAsFixed(val % 1 == 0 ? 0 : 1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final List<FlSpot> spots = [];

        if (timeframe == 'Daily') {
          for (int i = 0; i < 24; i++) {
            final targetHour = now.subtract(Duration(hours: 23 - i));
            double hourlyRevenue = 0.0;
            for (var order in provider.orders) {
              if (order.serviceDate.year == targetHour.year &&
                  order.serviceDate.month == targetHour.month &&
                  order.serviceDate.day == targetHour.day &&
                  order.serviceDate.hour == targetHour.hour) {
                hourlyRevenue += order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
              }
            }
            spots.add(FlSpot(i.toDouble(), hourlyRevenue));
          }
        } else if (timeframe == 'Weekly') {
          for (int i = 0; i < 7; i++) {
            final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
            double dailyRevenue = 0.0;
            for (var order in provider.orders) {
              if (order.serviceDate.year == date.year &&
                  order.serviceDate.month == date.month &&
                  order.serviceDate.day == date.day) {
                dailyRevenue += order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
              }
            }
            spots.add(FlSpot(i.toDouble(), dailyRevenue));
          }
        } else if (timeframe == 'Yearly') {
          for (int i = 0; i < 12; i++) {
            final monthOffset = now.month - (11 - i);
            final year = now.year + (monthOffset <= 0 ? (monthOffset - 12) ~/ 12 : 0);
            final month = monthOffset <= 0 ? 12 + (monthOffset % 12) : monthOffset;
            
            double monthlyRevenue = 0.0;
            for (var order in provider.orders) {
              if (order.serviceDate.year == year && order.serviceDate.month == month) {
                monthlyRevenue += order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
              }
            }
            spots.add(FlSpot(i.toDouble(), monthlyRevenue));
          }
        } else {
          // Monthly - 30 days
          for (int i = 0; i <= 30; i++) {
            final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 30 - i));
            double dailyRevenue = 0.0;
            for (var order in provider.orders) {
              if (order.serviceDate.year == date.year &&
                  order.serviceDate.month == date.month &&
                  order.serviceDate.day == date.day) {
                dailyRevenue += order.paymentStatus == 'Paid' ? order.totalAmount : order.advancePayment;
              }
            }
            spots.add(FlSpot(i.toDouble(), dailyRevenue));
          }
        }

        double maxRevenue = 1000;
        for (var spot in spots) {
          if (spot.y > maxRevenue) maxRevenue = spot.y;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${timeframe == 'Daily' ? 'Hourly' : (timeframe == 'Weekly' ? 'Daily' : (timeframe == 'Yearly' ? 'Monthly' : 'Daily'))} Revenue Trend'.toUpperCase(), 
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: RepaintBoundary(
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, 
                            reservedSize: 45, 
                            interval: (maxRevenue / 5).clamp(100.0, double.maxFinite),
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: SizedBox(
                                  width: 40,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatAmount(value),
                                      style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, 
                            reservedSize: 30, 
                            interval: timeframe == 'Daily' ? 4 : (timeframe == 'Weekly' ? 1 : (timeframe == 'Yearly' ? 1 : 7)),
                            getTitlesWidget: (value, meta) {
                              final intVal = value.toInt();
                              if (timeframe == 'Daily') {
                                if (intVal < 0 || intVal >= 24) return const SizedBox.shrink();
                                final targetHour = now.subtract(Duration(hours: 23 - intVal));
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: SizedBox(
                                    width: 28,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('${targetHour.hour}:00', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                    ),
                                  ),
                                );
                              } else if (timeframe == 'Weekly') {
                                if (intVal < 0 || intVal >= 7) return const SizedBox.shrink();
                                final targetDate = now.subtract(Duration(days: 6 - intVal));
                                final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: SizedBox(
                                    width: 28,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(days[targetDate.weekday % 7], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                    ),
                                  ),
                                );
                              } else if (timeframe == 'Yearly') {
                                if (intVal < 0 || intVal >= 12) return const SizedBox.shrink();
                                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                final monthOffset = now.month - (11 - intVal);
                                final month = monthOffset <= 0 ? 12 + (monthOffset % 12) : monthOffset;
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: SizedBox(
                                    width: 24,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(months[(month - 1) % 12], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                    ),
                                  ),
                                );
                              } else {
                                // Monthly
                                if (intVal < 0 || intVal > 30) return const SizedBox.shrink();
                                final date = now.subtract(Duration(days: 30 - intVal));
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: SizedBox(
                                    width: 28,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
