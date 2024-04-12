import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mememe/main_screen.dart';
import 'package:mememe/user_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (FirebaseAuth.instance.currentUser != null){
        final userId = FirebaseAuth.instance.currentUser?.uid;

        var userDoc = await FirebaseFirestore.instance
            .collection("users").doc(userId).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection("users").doc(userId).set(
              {
                "id": userId,
                "email": emailController.text
              }
          );
          userDoc = await FirebaseFirestore.instance
              .collection("users").doc(userId).get();
        }
        final user = userDoc.data();
        UserManager.instance.user = user!;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen())
        );
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Email',
            )
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Password',
            ),
            obscureText: true
          ),
          const Spacer(),
          ElevatedButton(onPressed: () async {
            final credential = await login();

            if (credential == null) {
              return;
            }

            final userId = credential.uid;

            var userDoc = await FirebaseFirestore.instance
                .collection("users").doc(userId).get();

            if (!userDoc.exists) {
              await FirebaseFirestore.instance
                  .collection("users").doc(userId).set(
                {
                  "id": userId,
                  "email": emailController.text
                }
              );
              userDoc = await FirebaseFirestore.instance
                  .collection("users").doc(userId).get();
            }
            final user = userDoc.data();
            UserManager.instance.user = user!;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen())
            );
          }, child: const Text("Login"))
        ],
      ),
    ));
  }

  Future<User?> login() async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );
      } else {
        rethrow;
      }
    }
    return credential.user;
  }
}
