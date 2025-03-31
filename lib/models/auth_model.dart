import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class AuthModel extends ChangeNotifier {
  String _username = 'AdminNV';
  String _password = 'Us12345@';
  bool _isAuthenticated = false;
  final DatabaseService _dbService = DatabaseService();

  bool get isAuthenticated => _isAuthenticated;
  String get username => _username;

  AuthModel() {
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result =
        await db.query('users', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      _username = result.first['username'];
      _password = result.first['password'];
      notifyListeners();
    }
  }

  bool login(String username, String password) {
    if (username == _username && password == _password) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateCredentials(String newUsername, String newPassword) async {
    _username = newUsername;
    _password = newPassword;
    final db = await _dbService.database;
    await db.update(
      'users',
      {'username': newUsername, 'password': newPassword},
      where: 'id = ?',
      whereArgs: [1],
    );
    notifyListeners();
  }
}
