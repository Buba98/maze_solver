import 'package:maze_solver/bloc/maze_bloc.dart';
import 'package:maze_solver/util/directions.dart';
import 'package:maze_solver/util/mathUtil.dart';

class Maze {
  final List<List<Cell>> _map = [];

  Maze(int rows, int columns) {
    init(rows: rows, columns: columns);
  }

  Maze.lateInit();

  void init({required int rows, required int columns}) {
    for (int row = 0; row < rows; row++) {
      _map.add([]);
      for (int column = 0; column < columns; column++) {
        Wall wallUp;
        Wall wallLeft;

        wallUp = row > 0 ? _map[row - 1][column].wallDown : Wall();

        wallLeft = column > 0 ? _map[row][column - 1].wallRight : Wall();

        _map[row].add(Cell(
            row: row,
            column: column,
            wallUp: wallUp,
            wallDown: Wall(),
            wallLeft: wallLeft,
            wallRight: Wall()));
      }
    }
  }

  int get rows => this._map.length;

  int get columns => this._map[0].length;

  List<Directions> getUnvisitedCellsDirections(Cell cell) {
    List<Directions> availableDirections = [];

    if (cell.row > 0 &&
        !getCell(row: cell.row - 1, column: cell.column).isVisited)
      availableDirections.add(Directions.UP);

    if (cell.row < this.rows - 1 &&
        !getCell(row: cell.row + 1, column: cell.column).isVisited)
      availableDirections.add(Directions.DOWN);

    if (cell.column > 0 &&
        !getCell(row: cell.row, column: cell.column - 1).isVisited)
      availableDirections.add(Directions.LEFT);

    if (cell.column < this.columns - 1 &&
        !getCell(row: cell.row, column: cell.column + 1).isVisited)
      availableDirections.add(Directions.RIGHT);

    return availableDirections;
  }

  Cell getCell({required int row, required int column}) => _map[row][column];

  Cell getCellByIndex({required int index}) =>
      getCell(row: index ~/ columns, column: index % columns);

  List<Cell> get unvisitedCells {
    List<Cell> unvisitedCells = [];
    _map.forEach((List<Cell> cells) => cells.forEach((Cell cell) {
          if (!cell.isVisited) unvisitedCells.add(cell);
        }));
    return unvisitedCells;
  }

  void recursiveRandomizedDepthFirstSearch({MazeBloc? mazeBloc}) {
    int start = MathUtils.randomNumberWithinRangeInclusiveFromZero(
        this.rows * this.columns - 1);

    _recursiveImplementation(
      cell: getCellByIndex(index: start),
      mazeBloc: mazeBloc,
    );
    mazeBloc?.add(DoneMaze());
  }

  void _recursiveImplementation({required Cell cell, MazeBloc? mazeBloc}) {
    cell.isVisited = true;
    List<Directions> availableDirections = getUnvisitedCellsDirections(cell);

    if (availableDirections.length > 0) {
      switch (availableDirections[
          MathUtils.randomNumberWithinRangeInclusiveFromZero(
              availableDirections.length - 1)]) {
        case Directions.UP:
          cell.wallUp.isWall = false;
          mazeBloc?.add(UpdateMaze(row1: cell.row, column1: cell.column));

          _recursiveImplementation(
            cell: getCell(row: cell.row - 1, column: cell.column),
            mazeBloc: mazeBloc,
          );
          break;
        case Directions.DOWN:
          cell.wallDown.isWall = false;
          mazeBloc?.add(UpdateMaze(row1: cell.row, column1: cell.column));

          _recursiveImplementation(
            cell: getCell(row: cell.row + 1, column: cell.column),
            mazeBloc: mazeBloc,
          );
          break;
        case Directions.LEFT:
          cell.wallLeft.isWall = false;
          mazeBloc?.add(UpdateMaze(row1: cell.row, column1: cell.column));

          _recursiveImplementation(
            cell: getCell(row: cell.row, column: cell.column - 1),
            mazeBloc: mazeBloc,
          );
          break;
        case Directions.RIGHT:
          cell.wallRight.isWall = false;
          mazeBloc?.add(UpdateMaze(row1: cell.row, column1: cell.column));

          _recursiveImplementation(
            cell: getCell(row: cell.row, column: cell.column + 1),
            mazeBloc: mazeBloc,
          );
          break;
      }

      _recursiveImplementation(
        cell: cell,
        mazeBloc: mazeBloc,
      );
    }
  }

  void randomizedKruskalAlgorithm({MazeBloc? mazeBloc}) {
    List<Wall> walls = [];
    List<List<Cell>> listsOfCells = [];

    _map.forEach((List<Cell> cells) => cells.forEach((Cell cell) {
          if (cell.row > 0) walls.add(cell.wallUp);
          if (cell.column > 0) walls.add(cell.wallLeft);
          listsOfCells.add([cell]);
        }));

    Wall wall;
    List<List<Cell>> cells1;

    while (walls.isNotEmpty) {
      cells1 = [];

      wall = walls.removeAt(
          MathUtils.randomNumberWithinRangeInclusiveFromZero(walls.length - 1));

      listsOfCells.forEach((List<Cell> cells) {
        if (cells.contains(wall.cells[0]) || cells.contains(wall.cells[1]))
          cells1.add(cells);
      });

      if (cells1.length != 2)
        continue;
      else if (cells1[0] == cells1[1])
        continue;
      else {
        listsOfCells.remove(cells1[1]);
        cells1[0].addAll(cells1[1]);
        wall.isWall = false;
        mazeBloc?.add(UpdateMaze(
          row1: wall.cells[0].row,
          column1: wall.cells[0].column,
          row2: wall.cells[1].row,
          column2: wall.cells[1].column,
        ));
      }
    }
    mazeBloc?.add(DoneMaze());
  }

  void randomizedPrimAlgorithm({MazeBloc? mazeBloc}) {
    Cell cell = getCellByIndex(
        index: MathUtils.randomNumberWithinRangeInclusiveFromZero(
            this.rows * this.columns - 1))
      ..isVisited = true;
    List<Wall> walls = [];
    cell.walls.forEach((Wall wall) {
      if (wall.cells.length == 2) walls.add(wall);
    });
    Wall wall;

    while (walls.isNotEmpty) {
      wall = walls.removeAt(
          MathUtils.randomNumberWithinRangeInclusiveFromZero(walls.length - 1));
      if (wall.cells[0].isVisited && wall.cells[1].isVisited)
        continue;
      else {
        wall.isWall = false;
        mazeBloc?.add(UpdateMaze(
          row1: wall.cells[0].row,
          column1: wall.cells[0].column,
          row2: wall.cells[1].row,
          column2: wall.cells[1].column,
        ));
        if (wall.cells[0].isVisited) {
          wall.cells[1]
            ..isVisited = true
            ..walls.forEach((Wall newWall) {
              if (newWall.isWall &&
                  !walls.contains(newWall) &&
                  newWall.cells.length == 2) walls.add(newWall);
            });
        } else {
          wall.cells[0]
            ..isVisited = true
            ..walls.forEach((Wall newWall) {
              if (newWall.isWall &&
                  !walls.contains(newWall) &&
                  newWall.cells.length == 2) walls.add(newWall);
            });
        }
      }
    }
    mazeBloc?.add(DoneMaze());
  }

  void randomizedAldousBroderAlgorithm({MazeBloc? mazeBloc}) {
    int numberUnvisitedCells = this.rows * this.columns;

    Cell cell = getCellByIndex(
        index: MathUtils.randomNumberWithinRangeInclusiveFromZero(
            numberUnvisitedCells - 1))
      ..isVisited = true;

    numberUnvisitedCells -= 1;

    List<Cell> neighbours;
    Cell neighbour;

    while (numberUnvisitedCells > 0) {
      neighbours = cell.neighbours;
      neighbour = neighbours[MathUtils.randomNumberWithinRangeInclusiveFromZero(
          neighbours.length - 1)];
      if (!neighbour.isVisited) {
        neighbour.isVisited = true;
        numberUnvisitedCells -= 1;
        for (Wall wall in cell.walls)
          if (wall.cells.contains(neighbour)) {
            wall.isWall = false;
            mazeBloc?.add(UpdateMaze(
                row1: wall.cells[0].row,
                column1: wall.cells[0].column,
                row2: wall.cells[1].row,
                column2: wall.cells[1].column));
            break;
          }
      }
      cell = neighbour;
    }
    mazeBloc?.add(DoneMaze());
  }
}

class Cell {
  final int row, column;
  final Wall wallUp, wallDown, wallLeft, wallRight;
  bool isVisited;

  Cell(
      {required this.row,
      required this.column,
      required this.wallUp,
      required this.wallDown,
      required this.wallLeft,
      required this.wallRight,
      this.isVisited = false}) {
    wallUp.cells.add(this);
    wallDown.cells.add(this);
    wallLeft.cells.add(this);
    wallRight.cells.add(this);
  }

  int get numberWallsOn {
    int i = 0;
    if (wallUp.isWall) i += 1;
    if (wallDown.isWall) i += 1;
    if (wallLeft.isWall) i += 1;
    if (wallRight.isWall) i += 1;

    return i;
  }

  List<Cell> get neighbours {
    List<Cell> neighbours = [];

    walls.forEach((Wall wall) => wall.cells.forEach((Cell cell) {
          if (cell != this) neighbours.add(cell);
        }));

    return neighbours;
  }

  int get numberWallsOff => 4 - numberWallsOn;

  List<Wall> get walls => [wallUp, wallDown, wallLeft, wallRight];

  List<Directions> get onWalls {
    List<Directions> walls = [];

    if (wallUp.isWall) walls.add(Directions.UP);
    if (wallDown.isWall) walls.add(Directions.DOWN);
    if (wallLeft.isWall) walls.add(Directions.LEFT);
    if (wallRight.isWall) walls.add(Directions.RIGHT);

    return walls;
  }

  List<Directions> get offWalls {
    List<Directions> walls = [];

    if (!wallUp.isWall) walls.add(Directions.UP);
    if (!wallDown.isWall) walls.add(Directions.DOWN);
    if (!wallLeft.isWall) walls.add(Directions.LEFT);
    if (!wallRight.isWall) walls.add(Directions.RIGHT);

    return walls;
  }
}

class Wall {
  bool isWall;
  List<Cell> cells = [];

  Wall({this.isWall = true});
}
