import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maze_solver/bloc/maze_generation_bloc.dart';
import 'package:maze_solver/model/maze.dart';
import 'package:maze_solver/page/maze_playing_page.dart';
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
                        Maze maze = state.maze!;

                        double squareDimension = min(
                          constraints.maxWidth / maze.columns,
                          (constraints.maxHeight / maze.rows) * .9,
                        );
                        return Column(
                          children: List.generate(
                            maze.rows,
                            (row) {
                              return Row(
                                children: List.generate(
                                  maze.columns,
                                  (column) => Container(
                                    child: CustomPaint(
                                      size: Size.square(squareDimension),
                                      painter: CustomPainterMazeSquare(
                                        isUseful: maze
                                            .getCell(row: row, column: column)
                                            .isUseful,
                                        cornerCorrectionUpLeft: column > 0 &&
                                            row > 0 &&
                                            maze
                                                .getCell(
                                                    row: row,
                                                    column: column - 1)
                                                .wallUp
                                                .isWall &&
                                            maze
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
                                        directions: maze
                                            .getCell(
                                              row: row,
                                              column: column,
                                            )
                                            .onWalls
                                          ..removeWhere(
                                            (Directions direction) {
                                              switch (direction) {
                                                case Directions.DOWN:
                                                  return row != maze.rows - 1;
                                                case Directions.RIGHT:
                                                  return column !=
                                                      maze.columns - 1;
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
                          )..add(
                              mazeBloc.state is ProcessingState ||
                                      mazeBloc.state is DoneState ||
                                      mazeBloc.state is SolvedState
                                  ? Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                mazeBloc.add(RestoreEvent());
                                                late StreamSubscription<
                                                    MazeGenerationState> stream;
                                                stream = mazeBloc.stream.listen(
                                                  (MazeGenerationState state) {
                                                    if (state is CreateState) {
                                                      mazeBloc.add(
                                                          AlgorithmChoiceEvent(
                                                              algorithm:
                                                                  choice));
                                                      stream.cancel();
                                                    }
                                                  },
                                                );
                                              },
                                              child: const Icon(Icons.refresh),
                                            ),
                                            Spacer(),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MazePlayingPage(
                                                                maze: mazeBloc
                                                                    .maze)));
                                              },
                                              child:
                                                  const Icon(Icons.play_arrow),
                                            ),
                                            Spacer(),
                                            ElevatedButton(
                                              onPressed: () => mazeBloc.add(
                                                SolveEvent(
                                                    startRow: 0,
                                                    startColumn: 0,
                                                    endRow: maze.rows - 1,
                                                    endColumn:
                                                        maze.columns - 1),
                                              ),
                                              child: const Icon(
                                                  Icons.download_done_rounded),
                                            ),
                                            Spacer(),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  mazeBloc.add(RestartEvent()),
                                              child: const Icon(
                                                  Icons.arrow_back_outlined),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: 0,
                                      height: 0,
                                    ),
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
    );
  }
}
