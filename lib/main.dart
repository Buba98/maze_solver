import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maze_solver/maze.dart';
import 'package:maze_solver/util/custom_painter_maze_square.dart';
import 'package:maze_solver/util/directions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Maze maze;

  @override
  void initState() {
    super.initState();
    maze = Maze(50, 50);
    // maze.recursiveRandomizedDepthFirstSearch();
    // maze.randomizedKruskalAlgorithm();
    // maze.randomizedPrimAlgorithm();
    maze.randomizedAldousBroderAlgorithm();
  }

  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double squareDimension = min(
                constraints.maxWidth / this.maze.columns,
                constraints.maxHeight / this.maze.rows);

            print(squareDimension);

            return Column(
              children: List.generate(
                this.maze.rows,
                (row) {
                  return Row(
                    children: List.generate(
                      this.maze.columns,
                      (column) => Container(
                        child: CustomPaint(
                          size: Size.square(squareDimension),
                          painter: CustomPainterMazeSquare(
                              directions: this
                                  .maze
                                  .getCell(row: row, column: column)
                                  .onWalls),
                        ),
                      ),
                    ),
                  );
                },
                growable: false,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
