import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mememe/login_screen.dart';
import 'package:mememe/movie_details_screen.dart';
import 'package:mememe/movies_screen.dart';
import 'package:mememe/movies_widget.dart';
import 'package:mememe/user_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  @override
  Widget build(BuildContext context) {
    final userId = UserManager.instance.user["id"];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
                tabs: [
                  Tab(text: "Movies"),
                  Tab(text: "Users")
                ]
            ),
            actions: [
              IconButton(onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginScreen())
                );
              }, icon: Icon(Icons.logout))
            ],
          ),
          body: TabBarView(
            children: [
              MoviesWidget(userId: userId),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection("users").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final users = snapshot.data?.docs ?? [];

                    return Column(
                      children: [
                        for (final user in users)
                          ListTile(
                              title: Text(user["email"]),
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => MoviesScreen(userId: user["id"])
                                    )
                                );
                              }
                          )
                      ],
                    );
                  }
              )
            ],
          )
      ),
    );
  }
}