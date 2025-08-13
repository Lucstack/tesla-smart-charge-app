import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class RatesScreen extends StatelessWidget {
  const RatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Energy Rates'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black87,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('energy_prices')
            .doc('NL')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No price data available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final Map<String, dynamic> hourlyRatesMap =
              snapshot.data!['hourlyRates'];

          final sortedKeys = hourlyRatesMap.keys.toList()
            ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

          final sortedPrices = List.from(
            sortedKeys.map((key) => hourlyRatesMap[key]['price'] as num),
          )..sort();
          final cheapThreshold = sortedPrices.length > 3
              ? sortedPrices[3]
              : sortedPrices.last;

          final List<BarChartGroupData> barGroups = sortedKeys.map((key) {
            final rateData = hourlyRatesMap[key];
            final hour = int.parse(key);
            final priceInCents = ((rateData['price'] as num) * 100).round();
            final isCheap = (rateData['price'] as num) <= cheapThreshold;

            return BarChartGroupData(
              x: hour,
              barRods: [
                BarChartRodData(
                  toY: priceInCents.toDouble(),
                  color: isCheap ? Colors.greenAccent : Colors.grey[700],
                  width: 14,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ],
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                // THE FIX IS HERE: .toDouble()
                maxY: ((sortedPrices.last * 100).round() + 5).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final price = rod.toY.round();
                      return BarTooltipItem(
                        '$price cents',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 3 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()}:00',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 5 == 0,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
              duration: const Duration(milliseconds: 250),
            ),
          );
        },
      ),
    );
  }
}
