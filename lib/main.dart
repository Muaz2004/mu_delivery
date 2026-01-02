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
    
    // Modern Palette Definitions
    const Color accentOrange = Color(0xFFFF7043);
    const Color modernLightBg = Color(0xFFF8F9FA); // Clean modern grey
    const Color modernDarkBg = Color(0xFF121212);  // Deep OLED black
    const Color textPrimaryLight = Color(0xFF2D2D2D);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MU Delivery',

      theme: ThemeData(
        useMaterial3: true,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: accentOrange,
        
        // Updated to modern clean background instead of Peach/Cream
        scaffoldBackgroundColor: isDarkMode ? modernDarkBg : modernLightBg,
        
        appBarTheme: AppBarTheme(
          // Transparent background so page titles feel integrated
          backgroundColor: Colors.transparent, 
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : textPrimaryLight,
          ),
          titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : textPrimaryLight,
            fontSize: 22,
            fontWeight: FontWeight.w900, // Modern heavy weight
            letterSpacing: -0.5,
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          selectedItemColor: accentOrange,
          unselectedItemColor: isDarkMode ? Colors.white54 : Colors.black38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Added CardThemeData to make sure all cards in the app match the 2025 look
        cardTheme: CardThemeData(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),

      home: const Wrapper(),
    );
  }
}