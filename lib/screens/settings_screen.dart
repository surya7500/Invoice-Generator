import 'package:flutter/material.dart';
import 'hotel_details_tab.dart';
import 'catalog_tab.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hotel Details'),
            Tab(text: 'Catalog'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HotelDetailsTab(),
          CatalogTab(),
        ],
      ),
    );
  }
}
