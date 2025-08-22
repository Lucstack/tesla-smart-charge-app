import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ConnectTeslaScreen extends StatefulWidget {
  const ConnectTeslaScreen({super.key});
  @override
  State<ConnectTeslaScreen> createState() => _ConnectTeslaScreenState();
}

class _ConnectTeslaScreenState extends State<ConnectTeslaScreen> {
  bool _isLoading = false;

  Future<void> _connectToTesla() async {
    setState(() {
      _isLoading = true;
    });

    // Make sure this is your NEW Client ID if you recreated the app
    const clientId = "761781a6-c268-4c39-8898-6ba264b1ff09";

    const redirectUri = "https://teslasmartchargeapp.web.app/callback";
    const callbackUrlScheme = "teslasmartchargeapp";
    const scopes =
        "openid offline_access vehicle_device_data vehicle_cmds vehicle_charging_cmds";

    final authUrl = Uri.https('auth.tesla.com', '/oauth2/v3/authorize', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes,
      'state': '12345',
      // --- THIS IS THE MISSING PIECE ---
      'audience': 'https://fleet-api.prd.na.vn.cloud.tesla.com',
    });

    print('Final Authorization URL: ${authUrl.toString()}');

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: callbackUrlScheme,
      );

      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
        final callable = functions.httpsCallable('exchangeAuthCodeForToken');
        await callable.call({'code': code});

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully connected to Tesla!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection failed or was cancelled.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Your Account'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.electric_car, size: 100, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              'Link Your Tesla Account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'To enable smart charging, we need permission to view your vehicle data and send charging commands.\n\nYou will be securely redirected to the official Tesla website to log in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _connectToTesla,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Connect to Tesla'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
