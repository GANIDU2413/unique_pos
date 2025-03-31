import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/database_service.dart';
import 'models/auth_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().initializeDatabase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
      ],
      child: UniqueSportsApp(),
    ),
  );
}

class UniqueSportsApp extends StatelessWidget {
  const UniqueSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unique Sports POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
