import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  final CollectionReference userDetails =
      FirebaseFirestore.instance.collection('user');
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  void checkUserRole() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      String uid = auth.currentUser!.uid;
      await userDetails.doc(uid).get().then((value) {
        if (value.exists) {
          Map<String, dynamic> userData = value.data() as Map<String, dynamic>;
          if (userData['role'] == 'Admin') {
            setState(() {
              isAdmin = true;
            });
          }
        }
      });
    } catch (e) {}
  }

  //Add new user from admin access
  final formKey1 = GlobalKey<FormState>();
  TextEditingController nameController2 = TextEditingController();
  TextEditingController emailController2 = TextEditingController();
  TextEditingController password2 = TextEditingController();
  TextEditingController mobile2 = TextEditingController();
  bool _isObscure2 = true;
  String _userRole = 'user';

  String hashPassword(String password, int i) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future addAccount() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    final cryptedPasswordAdmin = await hashPassword(password2.text.trim(), 12);
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController2.text.trim(),
      password: cryptedPasswordAdmin,
    );
    addUserData(cryptedPasswordAdmin);
    Navigator.pop(context);
  }

  Future addUserData(String cryptedPasswordAdmin) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid;

    await FirebaseFirestore.instance.collection('user').doc(uid).set({
      'name': nameController2.text.trim(),
      'email': emailController2.text.trim(),
      'password': cryptedPasswordAdmin,
      'mobile': mobile2.text.trim(),
      'role': _userRole,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New Account added'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  passwordUpdate(context);
                },
                child: const Text("Change Password")),
            const SizedBox(height: 12),
            if (isAdmin)
              ElevatedButton(
                onPressed: () async {
                  BuildContext currentContext = context;
                  showDialog(
                    context: currentContext,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: Center(
                          child: Dialog(
                            backgroundColor: Colors.white,
                            child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SingleChildScrollView(
                                  child: ListView(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(12),
                                      reverse: true,
                                      children: [
                                        Form(
                                          key: formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              TextFormField(
                                                controller: nameController2,
                                                decoration: InputDecoration(
                                                  hintText: 'Name',
                                                  hintStyle: const TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.greenAccent,
                                                      style: BorderStyle.solid,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter Name';
                                                  }

                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              TextFormField(
                                                controller: emailController2,
                                                decoration: InputDecoration(
                                                  hintText: 'Email',
                                                  hintStyle: const TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.greenAccent,
                                                      style: BorderStyle.solid,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      !EmailValidator.validate(
                                                          value)) {
                                                    return 'Please enter valid email';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              TextFormField(
                                                controller: password2,
                                                obscureText: _isObscure2,
                                                decoration: InputDecoration(
                                                  hintText: 'Password',
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _isObscure2
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      size: 12.0,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _isObscure2 =
                                                            !_isObscure2;
                                                      });
                                                    },
                                                  ),
                                                  hintStyle: const TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.greenAccent,
                                                      style: BorderStyle.solid,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter a password';
                                                  } else if (value.length < 8) {
                                                    return 'Password must be at least 8 characters long';
                                                  } else if (!value.contains(
                                                      RegExp(r'[A-Z]'))) {
                                                    return 'Password must contain at least one uppercase letter';
                                                  } else if (!value.contains(
                                                      RegExp(r'[a-z]'))) {
                                                    return 'Password must contain at least one lowercase letter';
                                                  } else if (!value.contains(
                                                      RegExp(r'[0-9]'))) {
                                                    return 'Password must contain at least one digit';
                                                  } else if (!value.contains(RegExp(
                                                      r'[!@#\$%\^&\*(),.?":{}|<>]'))) {
                                                    return 'Password must contain at least one special character';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              TextFormField(
                                                controller: mobile2,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: 'Mobile',
                                                  hintStyle: const TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.greenAccent,
                                                      style: BorderStyle.solid,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
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
                                              RadioListTile(
                                                  title: const Text("User"),
                                                  value: 'user',
                                                  groupValue: _userRole,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _userRole = 'user';
                                                    });
                                                  }),
                                              RadioListTile(
                                                  title: const Text("Admin"),
                                                  value: 'Admin',
                                                  groupValue: _userRole,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _userRole = 'Admin';
                                                    });
                                                  }),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Cancel"),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (formKey.currentState!
                                                          .validate()) {
                                                        addAccount();
                                                      }
                                                    },
                                                    child:
                                                        const Text("Add User"),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ].reversed.toList()),
                                )),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text("Add New User"),
              ),
          ],
        ),
      ),
    );
  }

  void passwordUpdate(BuildContext context) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(12),
                  reverse: true,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: currentPasswordController,
                            decoration: InputDecoration(
                              hintText: 'Current Password',
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
                              if (value!.isEmpty) {
                                return "Please enter current password";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: newPasswordController,
                            decoration: InputDecoration(
                              hintText: 'New Password',
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
                                return 'Please enter a password';
                              } else if (value.length < 8) {
                                return 'Password must be at least 8 characters long';
                              } else if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Password must contain at least one uppercase letter';
                              } else if (!value.contains(RegExp(r'[a-z]'))) {
                                return 'Password must contain at least one lowercase letter';
                              } else if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Password must contain at least one digit';
                              } else if (!value.contains(
                                  RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]'))) {
                                return 'Password must contain at least one special character';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ].reversed.toList(),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      onPressed: () {
                        currentPasswordController.text = '';
                        newPasswordController.text = '';
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        try {
                          User user = FirebaseAuth.instance.currentUser!;
                          bool hasPassword = user.providerData.any(
                              (provider) => provider.providerId == 'password');
                          if (!hasPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'User does not have a password set')),
                            );
                            return;
                          }
                          final cryptedCurrentPassword = await hashPassword(
                              currentPasswordController.text.trim(), 12);

                          String currentPassword = cryptedCurrentPassword;
                          AuthCredential credential =
                              EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentPassword,
                          );

                          await user.reauthenticateWithCredential(credential);
                          final cryptedNewPassword = await hashPassword(
                              newPasswordController.text.trim(), 12);

                          await user.updatePassword(cryptedNewPassword);

                          await userDetails
                              .doc(user.uid)
                              .update({'password': cryptedNewPassword});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('The password updated')),
                          );

                          currentPasswordController.clear();
                          newPasswordController.clear();
                          Navigator.pop(context);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'wrong-password') {
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'The current password entered is incorrect')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to update password: ${e.message}')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      child: const Text('Update Password'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
