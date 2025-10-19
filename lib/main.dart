import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mu_delivery/firebase_options.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:mu_delivery/providers/cart_provider.dart';
import 'package:mu_delivery/providers/theme_provider.dart';
import 'package:mu_delivery/wraper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => myProvider()), // auth provider
        ChangeNotifierProvider(create: (_) => CartProvider()), // cart provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // theme provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFFFF7043), // main home AppBar color
        scaffoldBackgroundColor: const Color(0xFFFFF3E0), // body default color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF3E0), // sub-pages AppBars
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const Wrapper(),
    );
  }
}
