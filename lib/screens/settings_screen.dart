import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesla_smart_charge_app/models/user_data.dart';
import 'package:tesla_smart_charge_app/screens/connect_tesla_screen.dart'; // Import the screen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // We keep the state management for the sliders
  late int _targetBattery;
  late int _emergencyThreshold;
  late int _chargingDuration;
  bool _isInitialized = false;

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

    if (!_isInitialized) {
      _targetBattery = userData.targetBattery;
      _emergencyThreshold = userData.emergencyThreshold;
      _chargingDuration = userData.chargingDuration;
      _isInitialized = true;
    }

    // --- NEW LOGIC: Check if Tesla is connected ---
    final bool isTeslaConnected =
        userData.vin != 'UNKNOWN' && userData.vin.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // --- NEW WIDGET: Show this card ONLY if not connected ---
          if (!isTeslaConnected)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.electric_car, color: Colors.blue),
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

          if (!isTeslaConnected) const Divider(height: 30, thickness: 1),

          Text(
            'Charging Preferences',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(height: 20, thickness: 1),

          // All the sliders remain the same...
          ListTile(
            title: const Text('Target Battery'),
            subtitle: Text(
              'Charge up to $_targetBattery% in the optimal window.',
            ),
          ),
          Slider(
            value: _targetBattery.toDouble(),
            min: 50,
            max: 100,
            divisions: 10,
            label: '$_targetBattery%',
            onChanged: (double value) {
              setState(() {
                _targetBattery = value.round();
              });
            },
            onChangeEnd: (double value) {
              _updateUserSetting('targetBattery', value.round());
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Emergency Threshold'),
            subtitle: Text(
              'Charge immediately if battery drops below $_emergencyThreshold%.',
            ),
          ),
          Slider(
            value: _emergencyThreshold.toDouble(),
            min: 10,
            max: 50,
            divisions: 8,
            label: '$_emergencyThreshold%',
            onChanged: (double value) {
              setState(() {
                _emergencyThreshold = value.round();
              });
            },
            onChangeEnd: (double value) {
              _updateUserSetting('emergencyThreshold', value.round());
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Charging Duration'),
            subtitle: Text('The number of hours needed to reach your target.'),
          ),
          Slider(
            value: _chargingDuration.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_chargingDuration hours',
            onChanged: (double value) {
              setState(() {
                _chargingDuration = value.round();
              });
            },
            onChangeEnd: (double value) {
              _updateUserSetting('chargingDuration', value.round());
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
