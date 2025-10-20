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
  scaffoldBackgroundColor: isDarkMode ? Colors.black : const Color(0xFFFFF3E0),
  appBarTheme: AppBarTheme(
    backgroundColor: isDarkMode ? Colors.black : const Color(0xFFFFF3E0),
    elevation: 0,
    iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
    titleTextStyle: TextStyle(
      color: isDarkMode ? Colors.white : Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
 bottomNavigationBarTheme: BottomNavigationBarThemeData(
  backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white, // dark gray for dark mode
  selectedItemColor: const Color(0xFFFF7043), // orange for selected
  unselectedItemColor: isDarkMode ? Colors.white : Colors.black54, // fully visible unselected
  selectedLabelStyle: const TextStyle(color: Color(0xFFFF7043)), // label for selected tab
  unselectedLabelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54), // label for unselected
  showUnselectedLabels: true,
),

),

      home: const Wrapper(),
    );
  }
}
