import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unique_pos/register_screen.dart';
import 'login_screen.dart';
import 'product_screen.dart';
import 'product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'POS System',
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => ProductScreen(),
          '/register': (context) => RegisterScreen(), // Add registration route
        },
      ),
    );
  }
}
