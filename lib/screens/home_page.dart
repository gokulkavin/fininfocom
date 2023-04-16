import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/screens/profile_page.dart';
import 'package:e_commerce/service/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    CollectionReference UserDetails =
        FirebaseFirestore.instance.collection('user');
    String? user = FirebaseAuth.instance.currentUser!.email;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.lightBlue,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 30),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/model.jpg'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user!),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back_rounded),
              title: const Text("Logout"),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => const AuthPage()));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: UserDetails.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final userData = snapshot.data!.docs[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Name: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(userData['name']),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text(
                                'Email: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(userData['email']),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text(
                                'Mobile: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(userData['mobile']),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text(
                                'Role: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(userData['role']),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
