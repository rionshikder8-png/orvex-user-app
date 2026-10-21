import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/l10n.dart';
import 'app_icons.dart';
import 'state_views.dart';

/// 7-day revenue bar chart. Shows an empty state when there is no data.
class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key, required this.series, this.height = 180});
  final List<double> series;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasData = series.isNotEmpty && series.any((v) => v > 0);
    if (!hasData) {
      return SizedBox(
        height: height,
        child: EmptyState(
          compact: true,
          icon: AppIcons.chart,
          title: context.t('chart_empty_title'),
          message: context.t('chart_empty_msg'),
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final maxY = series.reduce((a, b) => a > b ? a : b) * 1.2;
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String labelFor(int i) {
      final d = now.subtract(Duration(days: series.length - 1 - i));
      return days[d.weekday - 1];
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labelFor(v.toInt()),
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                rod.toY.round().toString(),
                TextStyle(
                  color: scheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < series.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: series[i],
                    width: 16,
                    color: scheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
