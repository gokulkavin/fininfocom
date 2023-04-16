import 'package:e_commerce/screens/home_page.dart';
import 'package:e_commerce/service/screenswitch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const ScreenSwitch();
          }
        },
      ),
    );
  }

  void logoutUser(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => const AuthPage()),
    );
  }
}
