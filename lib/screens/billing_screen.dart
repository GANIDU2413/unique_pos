import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/billing_item.dart';
import '../services/database_service.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<BillingItem> _stockItems = [];
  // ignore: prefer_final_fields
  List<BillingItem> _selectedItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    final items = await _dbService.getStockItems();
    setState(() {
      _stockItems = items
          .map((item) => BillingItem(
                id: item.id!,
                name: item.name,
                price: item.price,
              ))
          .toList();
    });
  }

  double get _totalAmount =>
      _selectedItems.fold(0, (sum, item) => sum + item.subtotal);

  void _addItem(BillingItem item) {
    setState(() {
      final existingItem = _selectedItems.firstWhere(
        (i) => i.id == item.id,
        orElse: () => item,
      );
      if (!_selectedItems.contains(existingItem)) {
        _selectedItems.add(item);
      } else {
        existingItem.quantity++;
      }
    });
  }

  void _removeItem(BillingItem item) {
    setState(() {
      _selectedItems.remove(item);
    });
  }

  void _updateQuantity(BillingItem item, int delta) {
    setState(() {
      item.quantity += delta;
      if (item.quantity <= 0) _removeItem(item);
    });
  }

  Future<void> _generateAndSaveBill() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No items in bill')));
      return;
    }

    await _dbService.saveBill(
        _selectedItems.map((item) => item.toMap()).toList(), _totalAmount);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Unique Sports - Bill', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Date: ${DateTime.now().toString()}'),
            pw.SizedBox(height: 20),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: ['Item', 'Price', 'Qty', 'Subtotal'],
              data: _selectedItems
                  .map((item) => [
                        item.name,
                        '\$${item.price.toStringAsFixed(2)}',
                        item.quantity.toString(),
                        '\$${item.subtotal.toStringAsFixed(2)}',
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total: \$${_totalAmount.toStringAsFixed(2)}',
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
          '${directory.path}/bill_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to access storage directory')),
      );
    }

    setState(() {
      _selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _stockItems
        .where((item) => item.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Billing')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addItem(item),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              children: [
                Text('Bill Summary',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._selectedItems.map((item) => ListTile(
                      title: Text(item.name),
                      subtitle: Text('\$${item.price} x ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => _updateQuantity(item, -1),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _updateQuantity(item, 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeItem(item),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 10),
                Text('Total: \$${_totalAmount.toStringAsFixed(2)}',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _generateAndSaveBill,
                  child: Text('Generate Bill & Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
