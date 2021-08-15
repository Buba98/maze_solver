import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maze_solver/bloc/maze_generation_bloc.dart';
import 'package:maze_solver/page/maze_solver_page.dart';
import 'package:maze_solver/util/custom_painter_maze_square.dart';
import 'package:maze_solver/util/directions.dart';

class MazeGenerationPage extends StatefulWidget {
  MazeGenerationPage({Key? key}) : super(key: key);

  @override
  _MazeGenerationPageState createState() => _MazeGenerationPageState();
}

class _MazeGenerationPageState extends State<MazeGenerationPage> {
  final MazeGenerationBloc mazeBloc = MazeGenerationBloc();
  final TextEditingController _controllerRows = TextEditingController();
  final TextEditingController _controllerColumns = TextEditingController();
  late Algorithms choice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: BlocBuilder(
                bloc: mazeBloc,
                builder: (BuildContext context, MazeGenerationState state) {
                  if (state is InitialState) {
                    return Form(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter rows',
                            ),
                            controller: _controllerRows,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter columns',
                            ),
                            controller: _controllerColumns,
                          ),
                          ElevatedButton(
                            onPressed: () => mazeBloc.add(CreateEvent(
                                rows: int.parse(_controllerRows.text),
                                columns: int.parse(_controllerColumns.text))),
                            child: const Text('Generate'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is CreateState) {
                    return Column(
                      children: List.generate(
                        Algorithms.values.length,
                        (index) => ElevatedButton(
                          onPressed: () {
                            mazeBloc.add(AlgorithmChoiceEvent(
                                algorithm: Algorithms.values[index]));
                            choice = Algorithms.values[index];
                          },
                          child: Text(Algorithms.values[index].toString()),
                        ),
                        growable: false,
                      ),
                    );
                  } else {
                    return LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double squareDimension = min(
                          constraints.maxWidth / state.maze.columns,
                          constraints.maxHeight / state.maze.rows,
                        );
                        return Column(
                          children: List.generate(
                            state.maze.rows,
                            (row) {
                              return Row(
                                children: List.generate(
                                  state.maze.columns,
                                  (column) => Container(
                                    child: CustomPaint(
                                      size: Size.square(squareDimension),
                                      painter: CustomPainterMazeSquare(
                                        cornerCorrectionUpLeft: column > 0 &&
                                            row > 0 &&
                                            state.maze
                                                .getCell(
                                                    row: row,
                                                    column: column - 1)
                                                .wallUp
                                                .isWall &&
                                            state.maze
                                                .getCell(
                                                    row: row - 1,
                                                    column: column)
                                                .wallLeft
                                                .isWall,
                                        cursor: state is ProcessingState
                                            ? (state.row1 == row &&
                                                    state.column1 == column) ||
                                                (state.row2 == row &&
                                                    state.column2 == column)
                                            : false,
                                        directions: state.maze
                                            .getCell(
                                              row: row,
                                              column: column,
                                            )
                                            .onWalls
                                          ..removeWhere(
                                            (Directions direction) {
                                              switch (direction) {
                                                case Directions.DOWN:
                                                  return row !=
                                                      state.maze.rows - 1;
                                                case Directions.RIGHT:
                                                  return column !=
                                                      state.maze.columns - 1;
                                                default:
                                                  return false;
                                              }
                                            },
                                          ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            growable: false,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MazeSolverPage(maze: mazeBloc.maze)));
          // mazeBloc.add(RestoreEvent());
          // mazeBloc.add(AlgorithmChoiceEvent(algorithm: choice));
        },
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.green,
      ),
    );
  }
}
