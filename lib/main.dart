import 'package:flutter/material.dart';
import 'package:maze_solver/page/maze_generation_page.dart';

void main() {
  runApp(MazeSolver());
}

class MazeSolver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MazeGenerationPage(),
    );
  }
}
