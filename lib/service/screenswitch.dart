import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../screens/signup.dart';

class ScreenSwitch extends StatefulWidget {
  const ScreenSwitch({Key? key}) : super(key: key);

  @override
  State<ScreenSwitch> createState() => _ScreenSwitchState();
}

class _ScreenSwitchState extends State<ScreenSwitch> {
  bool showSignUppage = true;

  void toggleScreen() {
    setState(() {
      showSignUppage = !showSignUppage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignUppage) {
      return Login(showSignUpPage: toggleScreen);
    } else {
      return SignUp(showLoginPage: toggleScreen);
    }
  }
}
