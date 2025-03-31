import 'dart:convert';

class Bill {
  final int id;
  final String date;
  final double total;
  final List<Map<String, dynamic>> items;

  Bill({
    required this.id,
    required this.date,
    required this.total,
    required this.items,
  });

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      date: map['date'],
      total: map['total'],
      items: List<Map<String, dynamic>>.from(jsonDecode(map['items'])),
    );
  }
}
