import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../screens/billing_screen.dart';
import '../screens/bill_history_screen.dart';
import '../screens/daily_sales_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/monthly_sales_screen.dart';
import '../screens/stock_management_screen.dart';
import '../screens/user_management_screen.dart';

class CustomDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Daily Sales', 'icon': Icons.today},
    {'title': 'Monthly Sales', 'icon': Icons.calendar_month},
    {'title': 'Stock Management', 'icon': Icons.inventory},
    {'title': 'Bill History', 'icon': Icons.history},
    {'title': 'User Management', 'icon': Icons.person},
    {'title': 'Billing', 'icon': Icons.receipt},
  ];

  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Center(
              child: Text('Unique Sports',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(menuItems[index]['icon']),
                title: Text(menuItems[index]['title']),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  if (menuItems[index]['title'] == 'Dashboard') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => DashboardScreen()));
                  } else if (menuItems[index]['title'] == 'Daily Sales') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => DailySalesScreen()));
                  } else if (menuItems[index]['title'] == 'Monthly Sales') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MonthlySalesScreen()));
                  } else if (menuItems[index]['title'] == 'Stock Management') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => StockManagementScreen()));
                  } else if (menuItems[index]['title'] == 'Bill History') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => BillHistoryScreen()));
                  } else if (menuItems[index]['title'] == 'User Management') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UserManagementScreen()));
                  } else if (menuItems[index]['title'] == 'Billing') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => BillingScreen()));
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Provider.of<AuthModel>(context, listen: false).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
