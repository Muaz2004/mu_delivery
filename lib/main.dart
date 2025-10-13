import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mu_delivery/coustemer_home_page.dart';
import 'package:mu_delivery/firebase_options.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:mu_delivery/signin_page.dart';
import 'package:mu_delivery/wraper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   runApp(
    ChangeNotifierProvider(
      create: (_) => myProvider(),
      child: const MyApp(),
    ),);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
  
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Wrapper(),
    
    
    );
  }
}


  
