import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/bill.dart';
import '../services/database_service.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BillHistoryScreenState createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Bill> _bills = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final bills = await _dbService.getBills();
    setState(() {
      _bills = bills;
    });
  }

  Future<void> _reprintBill(Bill bill) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Unique Sports - Bill Reprint',
                style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Date: ${bill.date}'),
            pw.SizedBox(height: 20),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: ['Item', 'Price', 'Qty', 'Subtotal'],
              data: bill.items
                  .map((item) => [
                        item['name'],
                        'Rs. ${item['price'].toStringAsFixed(2)}',
                        item['quantity'].toString(),
                        'Rs. ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total: Rs. ${bill.total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    // Use platform-aware directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      final file = File(
          '${directory.path}/bill_reprint_${bill.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to access storage directory')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBills = _bills
        .where((bill) => bill.date
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Bill History')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Date',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBills.length,
              itemBuilder: (context, index) {
                final bill = filteredBills[index];
                return ListTile(
                  title: Text('Bill #${bill.id} - ${bill.date}'),
                  subtitle: Text('Total: Rs. ${bill.total.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.print),
                    onPressed: () => _reprintBill(bill),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Bill Details'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Date: ${bill.date}'),
                              SizedBox(height: 10),
                              ...bill.items.map((item) => ListTile(
                                    title: Text(item['name']),
                                    subtitle: Text(
                                        'Price: Rs. ${item['price']} x ${item['quantity']} = Rs. ${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                                  )),
                              SizedBox(height: 10),
                              Text(
                                  'Total: Rs. ${bill.total.toStringAsFixed(2)}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              _reprintBill(bill);
                              Navigator.pop(context);
                            },
                            child: Text('Reprint'),
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
