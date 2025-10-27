import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/hotel_provider.dart';
import 'invoice_generator_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const InvoiceGeneratorScreen(),
    const SettingsScreen(),
  ];



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<HotelProvider>(
          builder: (context, hotelProvider, child) {
            final hotel = hotelProvider.hotelDetails;
            return Row(
              children: [
                if (hotel?.logoPath != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.file(File(hotel!.logoPath!), height: 30),
                  ),
                Text(hotel?.name ?? 'Restaurant POS'),
              ],
            );
          },
        ),
        elevation: 4,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
