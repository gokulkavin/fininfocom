import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final VoidCallback showSignUpPage;
  const Login({Key? key, required this.showSignUpPage}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isObscure = true;
  final formKey1 = GlobalKey<FormState>();

  String hashPassword(String password, int i) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Future logIn() async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return const Center(
  //         child: CircularProgressIndicator(),
  //       );
  //     },
  //   );
  //   try {
  //     final cryptedPasswordLogin = await hashPassword(password.text.trim(), 12);
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: emailController.text.trim(), password: cryptedPasswordLogin);
  //     Navigator.pop(context);
  //   } on FirebaseAuthException catch (e) {
  //     Navigator.pop(context);
  //     if (e.code == 'user-not-found') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('User does not exist. Please register.'),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(e.code),
  //         ),
  //       );
  //     }
  //   }
  // }


  Future logIn() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      final cryptedPasswordLogin = await hashPassword(password.text.trim(), 12);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(), password: cryptedPasswordLogin);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss the dialog
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss the dialog
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User does not exist. Please register.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.code),
          ),
        );
      }
    }
  }


  @override
  void dispose() {
    emailController.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            reverse: true,
            padding: const EdgeInsets.all(12),
            children: [
              Form(
                key: formKey1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.greenAccent,
                              style: BorderStyle.solid,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !EmailValidator.validate(value)) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: password,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 12.0,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          hintStyle: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.greenAccent,
                              style: BorderStyle.solid,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          } else if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password must contain at least one uppercase letter';
                          } else if (!value.contains(RegExp(r'[a-z]'))) {
                            return 'Password must contain at least one lowercase letter';
                          } else if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must contain at least one digit';
                          } else if (!value
                              .contains(RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]'))) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey1.currentState!.validate()) {
                            logIn();
                          }
                        },
                        child: const Text("Login"),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Not a Member",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.showSignUpPage,
                            child: const Text(
                              " Register here",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ].reversed.toList(),
          ),
        ),
      ),
    );
  }
}
