import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  final VoidCallback showLoginPage;
  const SignUp({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController mobile = TextEditingController();
  bool _isObscure = true;
  bool admin = false;

  String hashPassword(String password, int i) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future signIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    final cryptedPassword = await hashPassword(password.text.trim(), 12);
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: cryptedPassword,
    );
    addUserData(cryptedPassword);
    Navigator.pop(context);
  }

  Future addUserData(String cryptedPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid;
    await FirebaseFirestore.instance.collection('user').doc(uid).set({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': cryptedPassword,
      'mobile': mobile.text.trim(),
      'role':
          emailController.text.trim() == 'admin@gmail.com' ? "Admin" : "user",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              reverse: true,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Name',
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
                          if (value == null || value.isEmpty) {
                            return 'Please enter Name';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
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
                      TextFormField(
                        controller: mobile,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Mobile',
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
                              value.length < 10) {
                            return 'Please enter valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            signIn();
                          }
                        },
                        child: const Text("Sign Up"),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already a Member",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.showLoginPage,
                            child: const Text(
                              " Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ].reversed.toList()),
        ),
      ),
    );
  }
}
