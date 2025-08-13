import 'package:flutter/material.dart';
import 'package:tesla_smart_charge_app/screens/home_screen.dart';
import 'package:tesla_smart_charge_app/screens/rates_screen.dart';
import 'package:tesla_smart_charge_app/screens/savings_screen.dart';
import 'package:tesla_smart_charge_app/screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    RatesScreen(),
    SavingsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        // CHANGE: Updated the icons to better match the prototype
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Rates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            label: 'Savings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2C2C2E),
        selectedItemColor: const Color(0xFF4A5BF6),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true, // Show labels for better clarity
        showSelectedLabels: true,
      ),
    );
  }
}
