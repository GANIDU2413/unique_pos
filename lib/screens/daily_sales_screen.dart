import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/database_service.dart';

class DailySalesScreen extends StatefulWidget {
  @override
  _DailySalesScreenState createState() => _DailySalesScreenState();
}

class _DailySalesScreenState extends State<DailySalesScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Bill> _dailyBills = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailySales();
  }

  Future<void> _loadDailySales() async {
    final bills = await _dbService.getDailySales(_selectedDate);
    setState(() {
      _dailyBills = bills;
    });
  }

  double get _totalDailySales =>
      _dailyBills.fold(0, (sum, bill) => sum + bill.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Sales')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${_selectedDate.toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Sales: \$${_totalDailySales.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _dailyBills.isEmpty
                ? Center(child: Text('No sales for this day'))
                : ListView.builder(
                    itemCount: _dailyBills.length,
                    itemBuilder: (context, index) {
                      final bill = _dailyBills[index];
                      return ListTile(
                        title: Text(
                            'Bill #${bill.id} - ${bill.date.split('T')[1].substring(0, 8)}'),
                        subtitle:
                            Text('Total: \$${bill.total.toStringAsFixed(2)}'),
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
                                    ...bill.items.map((item) => ListTile(
                                          title: Text(item['name']),
                                          subtitle: Text(
                                              'Price: \$${item['price']} x ${item['quantity']} = \$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                                        )),
                                    SizedBox(height: 10),
                                    Text(
                                        'Total: \$${bill.total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
