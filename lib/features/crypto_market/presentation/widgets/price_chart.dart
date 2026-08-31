import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crypto_mart/features/settings/presentation/state/settings_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/chart_point_entity.dart';

class PriceChart extends StatefulWidget {
  final List<ChartPointEntity> points;
  final bool isPositive;
  final int selectedDays;
  final bool isChartLoading;
  final ValueChanged<int>? onDaysSelected;

  const PriceChart({
    super.key,
    required this.points,
    required this.isPositive,
    required this.selectedDays,
    this.isChartLoading = false,
    this.onDaysSelected,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final gridLineColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.5)
        : AppColors.borderLight;
    final chipBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final chipBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    final isChartGain = widget.points.isNotEmpty &&
        (widget.points.last.price >= widget.points.first.price);
    final lineColor =
        isChartGain ? AppColors.gainGreen : AppColors.lossRed;

    if (widget.points.isEmpty) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        child: Text(
          'Chart data unavailable',
          style: TextStyle(color: mutedTextColor),
        ),
      );
    }

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final currency = settingsState.selectedCurrency;

        final displayPoints = _prepareDisplayPoints(widget.points);

        final activePoint = (_touchedIndex != null &&
                _touchedIndex! >= 0 &&
                _touchedIndex! < displayPoints.length)
            ? displayPoints[_touchedIndex!]
            : displayPoints.last;

        final firstPoint = displayPoints.first;

        final activePriceConverted = activePoint.price * currency.rateFromUsd;
        final firstPriceConverted = firstPoint.price * currency.rateFromUsd;
        final priceDiff = activePriceConverted - firstPriceConverted;
        final percentChange = firstPriceConverted != 0
            ? (priceDiff / firstPriceConverted) * 100
            : 0.0;
        final isPointPositive = priceDiff >= 0;
        final pointColor =
            isPointPositive ? AppColors.gainGreen : AppColors.lossRed;

        final spots = displayPoints
            .asMap()
            .entries
            .map((e) =>
                FlSpot(e.key.toDouble(), e.value.price * currency.rateFromUsd))
            .toList();

        final rawMinY = displayPoints
            .map((p) => p.price * currency.rateFromUsd)
            .reduce((a, b) => a < b ? a : b);
        final rawMaxY = displayPoints
            .map((p) => p.price * currency.rateFromUsd)
            .reduce((a, b) => a > b ? a : b);

        final yRange = (rawMaxY - rawMinY) == 0 ? 1.0 : (rawMaxY - rawMinY);
        final computedMinY = rawMinY - (yRange * 0.08);
        final computedMaxY = rawMaxY + (yRange * 0.08);
        final yInterval = (yRange / 3).clamp(1.0, double.infinity);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Price & Timestamp Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${currency.symbol}${activePriceConverted.toStringAsFixed(activePriceConverted < 1.0 ? 4 : 2)}',
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currency.code,
                            style: TextStyle(
                              color: mutedTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: pointColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${isPointPositive ? '+' : ''}${currency.symbol}${priceDiff.abs().toStringAsFixed(2)} (${isPointPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                color: pointColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(
                            activePoint.timestamp, widget.selectedDays),
                        style: TextStyle(
                          color: mutedTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeframe selector chips
            if (widget.onDaysSelected != null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    (days: 1, label: '1D'),
                    (days: 7, label: '7D'),
                    (days: 30, label: '30D'),
                    (days: 365, label: '1Y'),
                    (days: 1825, label: '5Y'),
                  ].map((item) {
                    final isSelected = item.days == widget.selectedDays;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: isSelected,
                        checkmarkColor: Colors.white,
                        label: Text(item.label),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: chipBg,
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryBlue : chipBorder,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : secondaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _touchedIndex = null;
                          });
                          widget.onDaysSelected!(item.days);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 18),

            // Main Chart Canvas - Full Width, Tall Vertical Headroom
            SizedBox(
              height: 360,
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        height: 360,
                        child: LineChart(
                          LineChartData(
                            minY: computedMinY,
                            maxY: computedMaxY,
                            clipData: const FlClipData.all(),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: yInterval,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: gridLineColor,
                                  strokeWidth: 0.8,
                                  dashArray: [4, 4],
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: yInterval,
                                  getTitlesWidget: (value, meta) {
                                    if (value <= meta.min + 0.1 ||
                                        value >= meta.max - 0.1) {
                                      return const SizedBox.shrink();
                                    }
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _formatAxisPrice(value, currency.symbol),
                                        style: TextStyle(
                                          color: mutedTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 26,
                                  interval: displayPoints.length > 4
                                      ? (displayPoints.length / 4).toDouble()
                                      : 1.0,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= displayPoints.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final point = displayPoints[idx];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        _formatBottomAxisDate(
                                            point.timestamp, widget.selectedDays),
                                        style: TextStyle(
                                          color: mutedTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,
                              touchCallback:
                                  (FlTouchEvent event, LineTouchResponse? response) {
                                if (event is FlTapUpEvent ||
                                    event is FlPanEndEvent ||
                                    event is FlLongPressEnd) {
                                  setState(() {
                                    _touchedIndex = null;
                                  });
                                  return;
                                }
                                if (response == null ||
                                    response.lineBarSpots == null ||
                                    response.lineBarSpots!.isEmpty) {
                                  return;
                                }
                                final spotIndex =
                                    response.lineBarSpots!.first.spotIndex;
                                setState(() {
                                  _touchedIndex = spotIndex;
                                });
                              },
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData, List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: mutedTextColor,
                                      strokeWidth: 1,
                                      dashArray: [4, 4],
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 4.5,
                                        color: lineColor,
                                        strokeWidth: 2.5,
                                        strokeColor: isDark
                                            ? AppColors.surfaceDark
                                            : Colors.white,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (_) => isDark
                                    ? AppColors.surfaceDark.withValues(alpha: 0.95)
                                    : AppColors.surfaceLight.withValues(alpha: 0.95),
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      '${currency.symbol}${spot.y.toStringAsFixed(spot.y < 1.0 ? 4 : 2)}',
                                      TextStyle(
                                        color: primaryTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            showingTooltipIndicators: (_touchedIndex != null &&
                                    _touchedIndex! >= 0 &&
                                    _touchedIndex! < spots.length)
                                ? [
                                    ShowingTooltipIndicators([
                                      LineBarSpot(
                                        LineChartBarData(
                                          spots: spots,
                                          color: lineColor,
                                        ),
                                        0,
                                        spots[_touchedIndex!],
                                      ),
                                    ]),
                                  ]
                                : const [],
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                curveSmoothness: 0.20,
                                color: lineColor,
                                barWidth: 2.4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      lineColor.withValues(alpha: 0.25),
                                      lineColor.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (widget.isChartLoading)
                    Positioned.fill(
                      child: Container(
                        color: (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight)
                            .withValues(alpha: 0.65),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: isDark
                                  ? AppColors.accentCyanBright
                                  : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatAxisPrice(double price, String symbol) {
    if (price >= 1e9) {
      return '$symbol${(price / 1e9).toStringAsFixed(1)}B';
    } else if (price >= 1e6) {
      return '$symbol${(price / 1e6).toStringAsFixed(1)}M';
    } else if (price >= 1e3) {
      return '$symbol${(price / 1e3).toStringAsFixed(0)}K';
    }
    return '$symbol${price.toStringAsFixed(0)}';
  }

  String _formatTimestamp(DateTime dt, int days) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthName = months[dt.month - 1];
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;

    if (days <= 1) {
      return '$hour12:$minuteStr $period';
    } else if (days <= 30) {
      return '$monthName ${dt.day}, $hour12:$minuteStr $period';
    } else {
      return '$monthName ${dt.day}, ${dt.year}';
    }
  }

  String _formatBottomAxisDate(DateTime dt, int days) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthName = months[dt.month - 1];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    if (days <= 1) {
      return '$hour12 $period';
    } else if (days <= 30) {
      return '$monthName ${dt.day}';
    } else {
      return '${dt.year}';
    }
  }

  List<ChartPointEntity> _prepareDisplayPoints(List<ChartPointEntity> rawPoints) {
    if (rawPoints.length <= 80) return rawPoints;
    final step = (rawPoints.length / 75).ceil();
    final sampled = <ChartPointEntity>[];
    for (int i = 0; i < rawPoints.length; i += step) {
      sampled.add(rawPoints[i]);
    }
    if (sampled.isEmpty || sampled.last.timestamp != rawPoints.last.timestamp) {
      sampled.add(rawPoints.last);
    }
    return sampled;
  }
}
