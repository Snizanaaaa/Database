import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mememe/login_screen.dart';
import 'package:mememe/main_screen.dart';
import 'package:mememe/movie_details_screen.dart';

void main() async {
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDmmvfEjilUubiPQni7TJ2WQjpiwpLURCU",
        appId: "1:455154140162:web:1ac78041267cb67518131b",
        messagingSenderId: "455154140162",
        projectId: "syssss-non",
      ));

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen()
    );
  }
}
