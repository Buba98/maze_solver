import 'package:maze_solver/util/directions.dart';
import 'package:maze_solver/util/mathUtil.dart';

class Maze {
  late final List<List<Cell>> _map;
  late final int rows, columns;

  Maze(int rows, int columns) {
    this.rows = rows;
    this.columns = columns;
    this._map = [];

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

  /*void iterativeRandomizedDepthFirstSearch() {
    List<Cell> stack = [];
    List<Cell> unvisitedCells = this.unvisitedCells;

    stack.add(unvisitedCells.removeAt(
        MathUtils.randomNumberWithinRangeInclusiveFromZero(
            this.rows * this.columns - 1))
      ..isVisited = true);

    Cell currentCell;
    List<Directions> unvisitedCellsDirections;

    while (stack.isNotEmpty) {
      currentCell = stack.removeAt(
          MathUtils.randomNumberWithinRangeInclusiveFromZero(stack.length - 1));

      unvisitedCellsDirections = getUnvisitedCellsDirections(currentCell);

      if (unvisitedCellsDirections.isNotEmpty) {
        stack.add(currentCell);
        switch (unvisitedCellsDirections[
            MathUtils.randomNumberWithinRangeInclusiveFromZero(
                unvisitedCellsDirections.length - 1)]) {
          case Directions.UP:
            currentCell.wallUp.isWall = false;
            stack.add(
                getCell(row: currentCell.row + 1, column: currentCell.column)
                  ..isVisited = true);
            break;
          case Directions.DOWN:
            currentCell.wallDown.isWall = false;
            stack.add(
                getCell(row: currentCell.row - 1, column: currentCell.column)
                  ..isVisited = true);
            break;
          case Directions.LEFT:
            currentCell.wallLeft.isWall = false;
            stack.add(
                getCell(row: currentCell.row, column: currentCell.column - 1)
                  ..isVisited = true);
            break;
          case Directions.RIGHT:
            currentCell.wallRight.isWall = false;
            stack.add(
                getCell(row: currentCell.row, column: currentCell.column + 1)
                  ..isVisited = true);
            break;
        }
      }
    }
  }*/

  void recursiveRandomizedDepthFirstSearch() {
    int start = MathUtils.randomNumberWithinRangeInclusiveFromZero(
        this.rows * this.columns - 1);

    _recursiveImplementation(getCellByIndex(index: start));
  }

  void _recursiveImplementation(Cell cell) {
    cell.isVisited = true;
    List<Directions> availableDirections = getUnvisitedCellsDirections(cell);

    if (availableDirections.length > 0) {
      switch (availableDirections[
          MathUtils.randomNumberWithinRangeInclusiveFromZero(
              availableDirections.length - 1)]) {
        case Directions.UP:
          cell.wallUp.isWall = false;
          _recursiveImplementation(
              getCell(row: cell.row - 1, column: cell.column));
          break;
        case Directions.DOWN:
          cell.wallDown.isWall = false;

          _recursiveImplementation(
              getCell(row: cell.row + 1, column: cell.column));
          break;
        case Directions.LEFT:
          cell.wallLeft.isWall = false;

          _recursiveImplementation(
              getCell(row: cell.row, column: cell.column - 1));
          break;
        case Directions.RIGHT:
          cell.wallRight.isWall = false;

          _recursiveImplementation(
              getCell(row: cell.row, column: cell.column + 1));
          break;
      }

      _recursiveImplementation(cell);
    }
  }

  void debugPrintMaze() {
    String s;

    for (int row = 0; row < this.rows; row++) {
      s = "";
      for (int column = 0; column < this.columns; column++) {
        s += getCell(row: row, column: column).wallUp.isWall ? "oo" : "**";
      }
      print(s);

      s = "";
      for (int column = 0; column < this.columns; column++) {
        s += getCell(row: row, column: column).wallLeft.isWall ? "o" : "*";
        s += getCell(row: row, column: column).isVisited ? "*" : "!";
      }
      print(s);
    }

    s = "";
    for (int column = 0; column < this.columns; column++) {
      s += getCell(row: rows - 1, column: column).wallUp.isWall ? "oo" : "!!";
    }
    print(s);
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
      this.isVisited = false});

  int get numberWallsOn {
    int i = 0;
    if (wallUp.isWall) i += 1;
    if (wallDown.isWall) i += 1;
    if (wallLeft.isWall) i += 1;
    if (wallRight.isWall) i += 1;

    return i;
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

  Wall({this.isWall = true});
}
