import 'package:flutter/material.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for the savings dashboard.
    const double savingsThisMonth = 12.75;
    const int optimalCharges = 18;
    const double averageCost = 0.14;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Savings'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Main Savings Card
          _buildMetricCard(
            context: context,
            title: 'Savings This Month',
            value: '€${savingsThisMonth.toStringAsFixed(2)}',
            icon: Icons.savings,
            color: Colors.green,
          ),
          const SizedBox(height: 16),

          // Grid for secondary metrics
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true, // Important for nested scrolling
            physics:
                const NeverScrollableScrollPhysics(), // Disable grid's own scrolling
            children: <Widget>[
              _buildMetricCard(
                context: context,
                title: 'Optimal Charges',
                value: optimalCharges.toString(),
                icon: Icons.battery_charging_full,
                color: Colors.blue,
              ),
              _buildMetricCard(
                context: context,
                title: 'Avg. Cost',
                value: '€${averageCost.toStringAsFixed(2)}/kWh',
                icon: Icons.show_chart,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Placeholder Card
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Savings Over Time',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.bar_chart, size: 100, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text('Chart will be implemented here.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to avoid repeating card code.
  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
