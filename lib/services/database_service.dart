import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import '../models/stock_item.dart';
import '../models/bill.dart';
import 'dart:convert';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'unique_sports.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE stock (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            quantity INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE bills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            total REAL,
            items TEXT
          )
        ''');
        await db.rawInsert(
          'INSERT INTO users (username, password) VALUES (?, ?)',
          ['AdminNV', 'Us12345@'],
        );
        await db.rawInsert(
          'INSERT INTO stock (name, price, quantity) VALUES (?, ?, ?)',
          ['Football', 25.99, 10],
        );
        await db.rawInsert(
          'INSERT INTO stock (name, price, quantity) VALUES (?, ?, ?)',
          ['Basketball', 19.99, 15],
        );
      },
    );
  }

  Future<List<StockItem>> getStockItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('stock');
    return List.generate(maps.length, (i) => StockItem.fromMap(maps[i]));
  }

  Future<void> addStockItem(StockItem item) async {
    final db = await database;
    await db.insert('stock', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateStockItem(StockItem item) async {
    final db = await database;
    await db
        .update('stock', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteStockItem(int id) async {
    final db = await database;
    await db.delete('stock', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveBill(List<Map<String, dynamic>> items, double total) async {
    final db = await database;
    await db.insert(
      'bills',
      {
        'date': DateTime.now().toIso8601String(),
        'total': total,
        'items': jsonEncode(items)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Bill>> getBills() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('bills', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<List<Bill>> getDailySales(DateTime date) async {
    final db = await database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<List<Bill>> getMonthlySales(DateTime date) async {
    final db = await database;
    final startOfMonth = DateTime(date.year, date.month, 1).toIso8601String();
    final endOfMonth =
        DateTime(date.year, date.month + 1, 0, 23, 59, 59).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfMonth, endOfMonth],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }
}
