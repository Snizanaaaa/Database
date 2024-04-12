import 'package:flutter/material.dart';
import 'package:mememe/movies_widget.dart';

class MoviesScreen extends StatelessWidget {
  final String userId;
  const MoviesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: MoviesWidget(userId: userId));
  }
}
