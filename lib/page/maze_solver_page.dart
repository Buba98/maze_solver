import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maze_solver/bloc/maze_solving_bloc.dart';
import 'package:maze_solver/model/maze.dart';
import 'package:maze_solver/util/custom_painter_maze_square.dart';
import 'package:maze_solver/util/directions.dart';

class MazeSolverPage extends StatelessWidget {
  final Maze maze;
  late final MazeSolvingBloc bloc;

  MazeSolverPage({required this.maze}) {
    bloc = MazeSolvingBloc(maze: maze);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusScope(
        autofocus: true,
        child: Focus(
          onKey: (FocusNode node, RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
             if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                  event.logicalKey == LogicalKeyboardKey.keyW) {
                bloc.add(MoveSolvingEvent(directions: Directions.UP));
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                  event.logicalKey == LogicalKeyboardKey.keyS) {
                bloc.add(MoveSolvingEvent(directions: Directions.DOWN));

                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.keyA) {
                bloc.add(MoveSolvingEvent(directions: Directions.LEFT));

                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                  event.logicalKey == LogicalKeyboardKey.keyD) {
                bloc.add(MoveSolvingEvent(directions: Directions.RIGHT));

                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, MazeSolvingState state) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double squareDimension = min(
                    constraints.maxWidth / state.maze.columns,
                    constraints.maxHeight / state.maze.rows,
                  );
                  final FocusNode focusNode = Focus.of(context);

                  return GestureDetector(
                    onTap: () {
                      if (focusNode.hasFocus) {
                        focusNode.unfocus();
                      } else {
                        focusNode.requestFocus();
                      }
                    },
                    child: Column(
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
                                    isStart: state.rowStart == row && state.columnStart == column,
                                    isEnd: state.rowEnd == row && state.columnEnd == column,
                                    hasPlayer: state.player.row == row &&
                                        state.player.column == column,
                                    cornerCorrectionUpLeft: column > 0 &&
                                        row > 0 &&
                                        state.maze
                                            .getCell(
                                                row: row, column: column - 1)
                                            .wallUp
                                            .isWall &&
                                        state.maze
                                            .getCell(
                                                row: row - 1, column: column)
                                            .wallLeft
                                            .isWall,
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
                                              return row != state.maze.rows - 1;
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
