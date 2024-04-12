import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mememe/movie_details_screen.dart';
import 'package:mememe/user_manager.dart';

class MovieItemWidget extends StatefulWidget {
  final Map<String, dynamic> movie;
  final String userId;

  const MovieItemWidget({Key? key, required this.movie, required this.userId}) : super(key: key);

  @override
  _MovieItemWidgetState createState() => _MovieItemWidgetState();
}

class _MovieItemWidgetState extends State<MovieItemWidget> {
  int? _selectedRating;

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = UserManager.instance.user["id"] == widget.userId;
    return ListTile(
      leading: isCurrentUser ? GestureDetector(
        onTap: () {
          setState(() {
            widget.movie["watched"] = !widget.movie["watched"];
          });
          FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .collection("movies")
              .doc(widget.movie["id"])
              .update({"watched": widget.movie["watched"]});
        },
        child: Icon(
          widget.movie["watched"] ? Icons.visibility : Icons.visibility_off,
          color: widget.movie["watched"] ? Colors.green : null,
        ),
      ) : null,
      trailing: isCurrentUser ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = rating;
                  });

                  print("Selected rating: $_selectedRating");
                },
                child: Icon(
                  Icons.star,
                  color: _selectedRating != null && rating <= _selectedRating!
                      ? Colors.yellow
                      : Colors.grey,
                ),
              );
            }),
          ),

          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.userId)
                  .collection("movies")
                  .doc(widget.movie["id"])
                  .delete();
            },
          ),
        ],
      ) : null,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(title: widget.movie["title"], userId: widget.userId, movieId: widget.movie["id"],),
        ));
      },
      title: Text(
        widget.movie["title"],
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
