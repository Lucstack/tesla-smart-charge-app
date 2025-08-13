import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- The fix is here

class EnergyPrice {
  final String hour;
  final double price;

  EnergyPrice({required this.hour, required this.price});
}

class RatesScreen extends StatelessWidget {
  const RatesScreen({super.key});

  Color _getPriceColor(double price) {
    if (price < 0.12) return Colors.green;
    if (price > 0.25) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Energy Rates'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
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
            return const Center(child: Text('No price data available.'));
          }

          final Map<String, dynamic> hourlyRatesMap =
              snapshot.data!['hourlyRates'];

          final sortedKeys = hourlyRatesMap.keys.toList()
            ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

          final List<EnergyPrice> energyPrices = sortedKeys.map((key) {
            final rateData = hourlyRatesMap[key];
            final hourInt = int.tryParse(key) ?? 0;
            return EnergyPrice(
              hour: hourInt.toString().padLeft(2, '0') + ':00',
              price: (rateData['price'] as num).toDouble(),
            );
          }).toList();

          return ListView.builder(
            itemCount: energyPrices.length,
            itemBuilder: (context, index) {
              final item = energyPrices[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.timer_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    '${item.hour} - ${item.hour.split(':')[0]}:59',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriceColor(item.price),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '€${item.price.toStringAsFixed(3)}/kWh',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
