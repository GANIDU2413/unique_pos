import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import 'billing_screen.dart';
import 'bill_history_screen.dart';
import 'daily_sales_screen.dart';
import 'monthly_sales_screen.dart';
import 'stock_management_screen.dart';
import 'user_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      drawer: CustomDrawer(),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildDashboardCard('Daily Sales', Icons.today, Colors.blue, () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => DailySalesScreen()));
          }),
          _buildDashboardCard(
              'Monthly Sales', Icons.calendar_month, Colors.green, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => MonthlySalesScreen()));
          }),
          _buildDashboardCard(
              'Stock Management', Icons.inventory, Colors.orange, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => StockManagementScreen()));
          }),
          _buildDashboardCard('Bill History', Icons.history, Colors.purple, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => BillHistoryScreen()));
          }),
          _buildDashboardCard('User Management', Icons.person, Colors.red, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => UserManagementScreen()));
          }),
          _buildDashboardCard('Billing', Icons.receipt, Colors.teal, () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => BillingScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
