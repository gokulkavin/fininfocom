import 'package:e_commerce/service/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
     const MaterialApp(
       debugShowCheckedModeBanner: false,
      home: AuthPage(),
    ),
  );
}
