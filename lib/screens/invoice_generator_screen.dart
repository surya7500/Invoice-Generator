import 'package:flutter/material.dart';
import 'order_taking_tab.dart';
import 'dashboard_tab.dart';
import 'history_tab.dart';

class InvoiceGeneratorScreen extends StatefulWidget {
  const InvoiceGeneratorScreen({super.key});

  @override
  _InvoiceGeneratorScreenState createState() => _InvoiceGeneratorScreenState();
}

class _InvoiceGeneratorScreenState extends State<InvoiceGeneratorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Invoice Generator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Order Taking'),
            Tab(text: 'Dashboard'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrderTakingTab(),
          DashboardTab(),
          HistoryTab(),
        ],
      ),
    );
  }
}
