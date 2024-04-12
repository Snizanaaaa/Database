import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mememe/movie_details_screen.dart';
import 'package:mememe/user_manager.dart';

import 'movie_item_widget.dart';

class MoviesWidget extends StatefulWidget {
  final String userId;

  const MoviesWidget({super.key, required this.userId});

  @override
  State<MoviesWidget> createState() => _MoviesWidgetState();
}

class _MoviesWidgetState extends State<MoviesWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = UserManager.instance.user["id"] == widget.userId;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .collection("movies")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data?.docs ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final movie in movies)
                    MovieItemWidget(movie: movie.data(), userId: widget.userId),
                  if (isCurrentUser)
                    TextField(
                      controller: controller,
                      onSubmitted: (value) async {
                        final doc = FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.userId)
                            .collection("movies")
                            .doc();
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.userId)
                            .collection("movies")
                            .doc(doc.id)
                            .set({
                          "title": value,
                          "id": doc.id,
                          "watched": false

                        });
                        controller.clear();
                      },
                    )
                ],
              ),
            ),
          );
        });
  }
}