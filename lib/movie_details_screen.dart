import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String userId;
  final String movieId;
  final String title;
  const MovieDetailsScreen({Key? key, required this.title, required this.userId, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  static const apiKey = "d7bdbb79";
  final dio = Dio(BaseOptions(
      baseUrl: "http://www.omdbapi.com",
      queryParameters: {
        "apikey": apiKey
      }
  ));

  TextEditingController commentController = TextEditingController();
  List<String> comments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: getMovieDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;

                  if (data["Response"] == "False") {
                    return Center(child: Text(data["Error"]));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.network(data["Poster"]),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("IMDB: ${data["imdbRating"]}"),
                            SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                final imdbId = data['indbID'];
                                final url = "https://ww.imdb.com/title/$imdbId";
                                launchUrlString(url);
                              },
                              icon: Icon(Icons.open_in_new),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...(data["Genre"] as String).split(", ").map((genre) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(genre),
                            )),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Comments',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(comments[index]),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      addComment();
                    },
                    child: Text('Post'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getMovieDetails() async {
    final response = await dio.get("/", queryParameters: {
      "t": widget.title,
    });

    final data = response.data as Map<String, dynamic>;
    return data;
  }

  void addComment() {
    if (commentController.text.isNotEmpty) {
      setState(() {
        comments.add(commentController.text);
        FirebaseFirestore.instance.collection("users").doc(widget.userId).collection("movies").doc(widget.movieId).update(
            {"comment": commentController.text});
        commentController.clear();
      });
    }
  }
}
