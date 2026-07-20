import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_provider.dart';
import '../styles/app_colors.dart';

/// Bar chart of tickets attended (resolved) per day/week/month/year, with
/// a period selector. A single series, so it carries meaning through the
/// "Resolvido" status color rather than an arbitrary hue.
class AttendedChart extends ConsumerStatefulWidget {
  const AttendedChart({super.key});

  @override
  ConsumerState<AttendedChart> createState() => _AttendedChartState();
}

class _AttendedChartState extends ConsumerState<AttendedChart> {
  StatsPeriod _period = StatsPeriod.day;

  @override
  Widget build(BuildContext context) {
    final bucketsAsync = ref.watch(attendedStatsProvider(_period));
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chamados atendidos', style: text.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<StatsPeriod>(
              segments: const [
                ButtonSegment(value: StatsPeriod.day, label: Text('Dia')),
                ButtonSegment(value: StatsPeriod.week, label: Text('Semana')),
                ButtonSegment(value: StatsPeriod.month, label: Text('Mês')),
                ButtonSegment(value: StatsPeriod.year, label: Text('Ano')),
              ],
              selected: {_period},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _period = selection.first),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: bucketsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Text(
                    'Não foi possível carregar o gráfico.',
                    style: text.bodyMedium,
                  ),
                ),
                data: (buckets) => _AttendedBars(buckets: buckets),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendedBars extends StatelessWidget {
  const _AttendedBars({required this.buckets});

  final List<AttendedBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final maxCount = buckets.fold<int>(0, (max, b) => b.count > max ? b.count : max);
    final maxY = maxCount == 0 ? 4.0 : (maxCount * 1.25).ceilToDouble();
    final interval = (maxY / 4).clamp(1, double.infinity).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= buckets.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    buckets[index].label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              rod.toY.toInt().toString(),
              const TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].count.toDouble(),
                  color: AppColors.statusResolved,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
