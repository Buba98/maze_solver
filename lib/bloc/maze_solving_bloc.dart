import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maze_solver/model/maze.dart';
import 'package:maze_solver/model/player.dart';
import 'package:maze_solver/util/directions.dart';

//events

abstract class MazeSolvingEvent {}

class InitSolvingEvent extends MazeSolvingEvent {
  final Maze maze;
  final Player player;

  InitSolvingEvent({
    required this.maze,
    required this.player,
  });
}

class MoveSolvingEvent extends MazeSolvingEvent {
  final Directions directions;

  MoveSolvingEvent({required this.directions});
}

//states

abstract class MazeSolvingState {
  Maze maze;
  Player player;
  final int rowStart, columnStart;
  final int rowEnd, columnEnd;

  MazeSolvingState({
    required this.maze,
    required this.player,
    required this.rowStart,
    required this.columnStart,
    required this.rowEnd,
    required this.columnEnd,
  });
}

class DoneSolvingState extends MazeSolvingState {
  DoneSolvingState({
    required Maze maze,
    required Player player,
    required int rowStart,
    required int columnStart,
    required int rowEnd,
    required int columnEnd,
  }) : super(
          maze: maze,
          player: player,
          rowStart: rowStart,
          columnStart: columnStart,
          rowEnd: rowEnd,
          columnEnd: columnEnd,
        );
}

class UpdateSolvingState extends MazeSolvingState {
  UpdateSolvingState({
    required Maze maze,
    required Player player,
    required int rowStart,
    required int columnStart,
    required int rowEnd,
    required int columnEnd,
  }) : super(
          maze: maze,
          player: player,
          rowStart: rowStart,
          columnStart: columnStart,
          rowEnd: rowEnd,
          columnEnd: columnEnd,
        );
}

class InitialSolvingState extends MazeSolvingState {
  InitialSolvingState({
    required Maze maze,
    required Player player,
    required int rowStart,
    required int columnStart,
    required int rowEnd,
    required int columnEnd,
  }) : super(
          maze: maze,
          player: player,
          rowStart: rowStart,
          columnStart: columnStart,
          rowEnd: rowEnd,
          columnEnd: columnEnd,
        );
}

//bloc

class MazeSolvingBloc extends Bloc<MazeSolvingEvent, MazeSolvingState> {
  final Maze maze;
  late final Player player;
  late int rowStart, columnStart;
  late int rowEnd, columnEnd;

  MazeSolvingBloc({
    required this.maze,
  }) : super(
          InitialSolvingState(
            maze: maze,
            player: Player(
              row: 0,
              column: 0,
            ),
            rowStart: 0,
            rowEnd: maze.rows - 1,
            columnStart: 0,
            columnEnd: maze.columns - 1,
          ),
        ) {
    player = state.player;
    rowStart = state.rowStart;
    rowEnd = state.rowEnd;
    columnStart = state.columnStart;
    columnEnd = state.columnEnd;
  }

  @override
  Stream<MazeSolvingState> mapEventToState(MazeSolvingEvent event) async* {
    if (event is MoveSolvingEvent) {
      switch (event.directions) {
        case Directions.UP:
          if (!maze
              .getCell(row: player.row, column: player.column)
              .wallUp
              .isWall) {
            player.row--;
          }
          break;
        case Directions.DOWN:
          if (!maze
              .getCell(row: player.row, column: player.column)
              .wallDown
              .isWall) {
            player.row++;
          }
          break;
        case Directions.LEFT:
          if (!maze
              .getCell(row: player.row, column: player.column)
              .wallLeft
              .isWall) {
            player.column--;
          }
          break;
        case Directions.RIGHT:
          if (!maze
              .getCell(row: player.row, column: player.column)
              .wallRight
              .isWall) {
            player.column++;
          }
          break;
      }
      if (rowEnd == player.row && columnEnd == player.column) {
        yield DoneSolvingState(
          maze: maze,
          player: player,
          rowStart: rowStart,
          columnStart: columnStart,
          rowEnd: rowEnd,
          columnEnd: columnEnd,
        );
      } else {
        yield UpdateSolvingState(
          maze: maze,
          player: player,
          rowStart: rowStart,
          columnStart: columnStart,
          rowEnd: rowEnd,
          columnEnd: columnEnd,
        );
      }
    }
  }
}
