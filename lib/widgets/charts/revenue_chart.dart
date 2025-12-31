import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                return Text(months[value.toInt() % 6]);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('\$${value.toInt()}');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1500),
              FlSpot(1, 2800),
              FlSpot(2, 2000),
              FlSpot(3, 3500),
              FlSpot(4, 3000),
              FlSpot(5, 4500),
            ],
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true),
          ),
        ],
      ),
    );
  }
}