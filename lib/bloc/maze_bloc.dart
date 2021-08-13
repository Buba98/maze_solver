import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maze_solver/model/maze.dart';
import 'package:maze_solver/util/directions.dart';

//algorithms

enum Algorithms {
  RANDOMIZED_KRUSKAL,
  RECURSIVE_RANDOMIZED_DEPTH_FIRST_SEARCH,
  RANDOMIZED_PRIM,
  RANDOMIZED_ALDOUS_BRODER,
}

//events

abstract class MazeEvent {
  MazeEvent();
}

class DoneMaze extends MazeEvent {}

class AlgorithmChoice extends MazeEvent {
  final Algorithms algorithm;

  AlgorithmChoice({required this.algorithm});
}

class UpdateMaze extends MazeEvent {
  final int? row1, column1;
  final int? row2, column2;

  UpdateMaze({
    this.row1,
    this.column1,
    this.row2,
    this.column2,
  });
}

class CreateMaze extends MazeEvent {
  final int rows, columns;

  CreateMaze({
    required this.rows,
    required this.columns,
  });
}

//states

abstract class MazeState {
  Maze maze;

  MazeState({required this.maze});
}

class InitialState extends MazeState {
  InitialState() : super(maze: Maze.lateInit());
}

class CreateState extends MazeState {
  CreateState({required Maze maze}) : super(maze: maze);
}

class ProcessingState extends MazeState {
  final int? row1, column1;
  final int? row2, column2;

  ProcessingState(
      {required Maze maze, this.row1, this.column1, this.row2, this.column2})
      : super(maze: maze);
}

class DoneState extends MazeState {
  DoneState({required Maze maze}) : super(maze: maze);
}

//bloc

class MazeBloc extends Bloc<MazeEvent, MazeState> {
  late final Maze maze;

  MazeBloc() : super(InitialState()) {
    maze = this.state.maze;
  }

  @override
  Stream<MazeState> mapEventToState(MazeEvent event) async* {
    if (event is CreateMaze) {
      maze.init(rows: event.rows, columns: event.columns);
      yield CreateState(maze: maze);
    } else if (event is AlgorithmChoice) {
      switch (event.algorithm) {
        case Algorithms.RANDOMIZED_KRUSKAL:
          maze.randomizedKruskalAlgorithm(mazeBloc: this);
          break;
        case Algorithms.RECURSIVE_RANDOMIZED_DEPTH_FIRST_SEARCH:
          maze.recursiveRandomizedDepthFirstSearch(mazeBloc: this);
          break;
        case Algorithms.RANDOMIZED_PRIM:
          maze.randomizedPrimAlgorithm(mazeBloc: this);
          break;
        case Algorithms.RANDOMIZED_ALDOUS_BRODER:
          maze.randomizedAldousBroderAlgorithm(mazeBloc: this);
          break;
      }
    } else if (event is UpdateMaze) {
      yield ProcessingState(
        maze: maze,
        row1: event.row1,
        column1: event.column1,
        row2: event.row2,
        column2: event.column2,
      );
    } else if (event is DoneMaze) {
      yield DoneState(maze: maze);
    }
  }
}