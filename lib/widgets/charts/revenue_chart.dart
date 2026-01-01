import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  final double totalRevenue;

  const RevenueChart({super.key, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    // Generate realistic monthly data based on total revenue
    final monthlyData = _generateMonthlyData(totalRevenue);

    return LineChart(
      LineChartData(
        minY: 0,
        minX: 0,
        maxX: 5,
        maxY: _getMaxY(monthlyData),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200],
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _getInterval(totalRevenue),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '\$${value.toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.3,
            barWidth: 3,
            color: Colors.blue,
            shadow: Shadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.1),
                ],
              ),
            ),
            spots: monthlyData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<double> _generateMonthlyData(double totalRevenue) {
    if (totalRevenue == 0) {
      return List.generate(6, (_) => 0.0);
    }

    // Create realistic distribution (not just equal parts)
    final percentages = [0.1, 0.15, 0.12, 0.18, 0.2, 0.25]; // Increasing trend
    return percentages.map((percent) => totalRevenue * percent).toList();
  }

  double _getMaxY(List<double> data) {
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    // Round up to nearest 1000 for better Y-axis scaling
    return ((maxValue * 1.2) ~/ 1000 + 1) * 1000;
  }

  double _getInterval(double totalRevenue) {
    if (totalRevenue <= 1000) return 200;
    if (totalRevenue <= 5000) return 1000;
    if (totalRevenue <= 20000) return 2000;
    return 5000;
  }
}