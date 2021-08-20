import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maze_solver/model/maze.dart';
import 'package:maze_solver/model/player.dart';
import 'package:maze_solver/util/directions.dart';

//events

abstract class MazePlayingEvent {}

class InitPlayingEvent extends MazePlayingEvent {
  final Maze maze;
  final Player player;

  InitPlayingEvent({
    required this.maze,
    required this.player,
  });
}

class MovePlayingEvent extends MazePlayingEvent {
  final Directions directions;

  MovePlayingEvent({required this.directions});
}

//states

abstract class MazePlayingState {
  Maze maze;
  Player player;
  final int rowStart, columnStart;
  final int rowEnd, columnEnd;

  MazePlayingState({
    required this.maze,
    required this.player,
    required this.rowStart,
    required this.columnStart,
    required this.rowEnd,
    required this.columnEnd,
  });
}

class DonePlayingState extends MazePlayingState {
  DonePlayingState({
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

class UpdatePlayingState extends MazePlayingState {
  UpdatePlayingState({
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

class InitialPlayingState extends MazePlayingState {
  InitialPlayingState({
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

class MazePlayingBloc extends Bloc<MazePlayingEvent, MazePlayingState> {
  final Maze maze;
  late final Player player;
  late int rowStart, columnStart;
  late int rowEnd, columnEnd;

  MazePlayingBloc({
    required this.maze,
  }) : super(
          InitialPlayingState(
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
  Stream<MazePlayingState> mapEventToState(MazePlayingEvent event) async* {
    if (event is MovePlayingEvent) {
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
        yield DonePlayingState(
          maze: maze,
          player: player,
          rowStart: rowStart,
          columnStart: columnStart,
          rowEnd: rowEnd,
          columnEnd: columnEnd,
        );
      } else {
        yield UpdatePlayingState(
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
