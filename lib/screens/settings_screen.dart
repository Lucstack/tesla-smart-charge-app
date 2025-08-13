import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesla_smart_charge_app/models/user_data.dart';
import 'package:tesla_smart_charge_app/widgets/custom_slider.dart';
import 'package:tesla_smart_charge_app/screens/connect_tesla_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // We only need local state for the toggle, as it has a visual on/off state.
  // The sliders will now get their values directly from the provider.
  bool? _solarChargingEnabled;

  Future<void> _updateUserSetting(String field, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'settings.$field': value},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    final theme = Theme.of(context);
    // Initialize the toggle's state if it hasn't been set yet.
    _solarChargingEnabled ??= userData.solarChargingEnabled;

    // --- THIS IS THE CRUCIAL CHECK ---
    // We read directly from the provider every time the widget builds.
    final bool isTeslaConnected =
        userData.vin != 'UNKNOWN' && userData.vin.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          // Show the "Connect" card if the user is not connected.
          if (!isTeslaConnected)
            Card(
              color: Colors.blue[900]?.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.electric_car, color: Colors.white),
                      title: Text('Connect Your Tesla Account'),
                      subtitle: Text(
                        'Enable smart charging by linking your account.',
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Connect Now'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ConnectTeslaScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          if (!isTeslaConnected) const SizedBox(height: 32),

          Text('Charging', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSliderRow(
                  title: 'Charging Duration',
                  valueText: '${userData.chargingDuration} hours',
                  slider: CustomSlider(
                    value: userData.chargingDuration.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '${userData.chargingDuration} hours',
                    onChanged: (value) {
                      /* We don't need instant UI update here */
                    },
                    onChangeEnd: (value) =>
                        _updateUserSetting('chargingDuration', value.round()),
                  ),
                ),
                _buildSliderRow(
                  title: 'Target Battery %',
                  valueText: '${userData.targetBattery}%',
                  slider: CustomSlider(
                    value: userData.targetBattery.toDouble(),
                    min: 50,
                    max: 100,
                    divisions: 10,
                    label: '${userData.targetBattery}%',
                    onChanged: (value) {
                      /* No need for instant update */
                    },
                    onChangeEnd: (value) =>
                        _updateUserSetting('targetBattery', value.round()),
                  ),
                ),
                _buildSliderRow(
                  title: 'Emergency Threshold %',
                  valueText: '${userData.emergencyThreshold}%',
                  slider: CustomSlider(
                    value: userData.emergencyThreshold.toDouble(),
                    min: 10,
                    max: 50,
                    divisions: 8,
                    label: '${userData.emergencyThreshold}%',
                    onChanged: (value) {
                      /* No need for instant update */
                    },
                    onChangeEnd: (value) =>
                        _updateUserSetting('emergencyThreshold', value.round()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Advanced', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text(
                'Solar Only Charging',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'When enabled, will only charge using excess solar power.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              value: _solarChargingEnabled!,
              onChanged: (value) {
                setState(() => _solarChargingEnabled = value);
                _updateUserSetting('solarChargingEnabled', value);
              },
              activeColor: theme.primaryColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2C2E),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text(
              'Log Out',
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String title,
    required String valueText,
    required Widget slider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(valueText, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        slider,
      ],
    );
  }
}
