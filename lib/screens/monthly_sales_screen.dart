import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/database_service.dart';

class MonthlySalesScreen extends StatefulWidget {
  const MonthlySalesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MonthlySalesScreenState createState() => _MonthlySalesScreenState();
}

class _MonthlySalesScreenState extends State<MonthlySalesScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Bill> _monthlyBills = [];
  final DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMonthlySales();
  }

  Future<void> _loadMonthlySales() async {
    final bills = await _dbService.getMonthlySales(_selectedMonth);
    setState(() {
      _monthlyBills = bills;
    });
  }

  double get _totalMonthlySales =>
      _monthlyBills.fold(0, (sum, bill) => sum + bill.total);

  Map<String, double> _dailyTotals() {
    final Map<String, double> totals = {};
    for (var bill in _monthlyBills) {
      final date = bill.date.split('T')[0];
      totals[date] = (totals[date] ?? 0) + bill.total;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final dailyTotals = _dailyTotals();

    return Scaffold(
      appBar: AppBar(title: Text('Monthly Sales')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Month: ${_selectedMonth.month}/${_selectedMonth.year}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Sales: \$${_totalMonthlySales.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _monthlyBills.isEmpty
                ? Center(child: Text('No sales for this month'))
                : ListView(
                    children: dailyTotals.entries.map((entry) {
                      final date = entry.key;
                      final total = entry.value;
                      return ExpansionTile(
                        title: Text('Date: $date'),
                        subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
                        children: _monthlyBills
                            .where((bill) => bill.date.split('T')[0] == date)
                            .map((bill) => ListTile(
                                  title: Text(
                                      'Bill #${bill.id} - ${bill.date.split('T')[1].substring(0, 8)}'),
                                  subtitle: Text(
                                      'Total: \$${bill.total.toStringAsFixed(2)}'),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Bill #${bill.id} Details'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Date: ${bill.date}'),
                                              SizedBox(height: 10),
                                              ...bill.items
                                                  .map((item) => ListTile(
                                                        title:
                                                            Text(item['name']),
                                                        subtitle: Text(
                                                            'Price: \$${item['price']} x ${item['quantity']} = \$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                                                      )),
                                              SizedBox(height: 10),
                                              Text(
                                                  'Total: \$${bill.total.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ))
                            .toList(),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
