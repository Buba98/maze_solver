import 'package:maze_solver/bloc/maze_generation_bloc.dart';
import 'package:maze_solver/util/directions.dart';
import 'package:maze_solver/util/mathUtil.dart';

class Maze {
  final List<List<Cell>> _map = [];

  Maze({required int rows, required int columns}) {
    init(rows: rows, columns: columns);
  }

  void restore() {
    for (List<Cell> cells in _map) {
      for (Cell cell in cells) {
        cell.isVisited = false;
        cell.isUseful = true;
        for (Wall wall in cell.walls) {
          wall.isWall = true;
        }
      }
    }
  }

  void solveMaze({
    required int startRow,
    required int startColumn,
    required int endRow,
    required int endColumn,
  }) {
    bool modified = true;

    Cell cellStart = getCell(row: startRow, column: startColumn);
    Cell cellEnd = getCell(row: endRow, column: endColumn);

    while (modified) {
      modified = false;
      _map.forEach(
        (List<Cell> cells) => cells.forEach(
          (Cell cell) {
            if (cell != cellStart && cell != cellEnd && cell.isUseful) {
              if (cell.usefulSimplyConnectedNeighbors.length < 2) {
                cell.isUseful = false;
                modified = true;
              }
            }
          },
        ),
      );
    }
  }

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

  void iterativeRandomizedDepthFirstSearch({MazeGenerationBloc? mazeBloc}) {
    List<Cell> stack = [
      getCellByIndex(
          index: MathUtils.randomNumberWithinRangeInclusiveFromZero(
              this.rows * this.columns - 1))
        ..isVisited = true
    ];

    Cell currentCell;
    Cell chosenCell;
    List<Cell> unvisitedNeighbours;

    while (stack.isNotEmpty) {
      currentCell = stack.removeAt(
          MathUtils.randomNumberWithinRangeInclusiveFromZero(stack.length - 1));

      unvisitedNeighbours = [];

      for (Cell neighbour in currentCell.neighbours) {
        if (!neighbour.isVisited) unvisitedNeighbours.add(neighbour);
      }

      if (unvisitedNeighbours.isNotEmpty) {
        stack.add(currentCell);

        chosenCell = unvisitedNeighbours[
            MathUtils.randomNumberWithinRangeInclusiveFromZero(
                unvisitedNeighbours.length - 1)];

        for (Wall wall in chosenCell.walls) {
          if (wall.cells.contains(currentCell)) {
            wall.isWall = false;
            chosenCell.isVisited = true;
            mazeBloc?.add(
              UpdateEvent(
                row1: wall.cells[0].row,
                column1: wall.cells[0].column,
                row2: wall.cells[1].row,
                column2: wall.cells[1].column,
              ),
            );
            stack.add(chosenCell);
            break;
          }
        }
      }
    }
    mazeBloc?.add(DoneEvent());
  }

  void recursiveRandomizedDepthFirstSearch({MazeGenerationBloc? mazeBloc}) {
    int start = MathUtils.randomNumberWithinRangeInclusiveFromZero(
        this.rows * this.columns - 1);

    _recursiveImplementation(
      cell: getCellByIndex(index: start),
      mazeBloc: mazeBloc,
    );
    mazeBloc?.add(DoneEvent());
  }

  void _recursiveImplementation(
      {required Cell cell, MazeGenerationBloc? mazeBloc}) {
    cell.isVisited = true;
    List<Directions> availableDirections = getUnvisitedCellsDirections(cell);

    if (availableDirections.length > 0) {
      switch (availableDirections[
          MathUtils.randomNumberWithinRangeInclusiveFromZero(
              availableDirections.length - 1)]) {
        case Directions.UP:
          cell.wallUp.isWall = false;
          mazeBloc?.add(UpdateEvent(row1: cell.row, column1: cell.column));

          _recursiveImplementation(
            cell: getCell(row: cell.row - 1, column: cell.column),
            mazeBloc: mazeBloc,
          );
          break;
        case Directions.DOWN:
          cell.wallDown.isWall = false;
          mazeBloc?.add(UpdateEvent(row1: cell.row, column1: cell.column));

          _recursiveImplementation(
            cell: getCell(row: cell.row + 1, column: cell.column),
            mazeBloc: mazeBloc,
          );
          break;
        case Directions.LEFT:
          cell.wallLeft.isWall = false;
          mazeBloc?.add(UpdateEvent(row1: cell.row, column1: cell.column));

          _recursiveImplementation(
            cell: getCell(row: cell.row, column: cell.column - 1),
            mazeBloc: mazeBloc,
          );
          break;
        case Directions.RIGHT:
          cell.wallRight.isWall = false;
          mazeBloc?.add(UpdateEvent(row1: cell.row, column1: cell.column));

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

  void randomizedKruskalAlgorithm({MazeGenerationBloc? mazeBloc}) {
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
        mazeBloc?.add(UpdateEvent(
          row1: wall.cells[0].row,
          column1: wall.cells[0].column,
          row2: wall.cells[1].row,
          column2: wall.cells[1].column,
        ));
      }
    }
    mazeBloc?.add(DoneEvent());
  }

  void randomizedPrimAlgorithm({MazeGenerationBloc? mazeBloc}) {
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
        mazeBloc?.add(UpdateEvent(
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
    mazeBloc?.add(DoneEvent());
  }

  void randomizedAldousBroderAlgorithm({MazeGenerationBloc? mazeBloc}) {
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
            mazeBloc?.add(UpdateEvent(
                row1: wall.cells[0].row,
                column1: wall.cells[0].column,
                row2: wall.cells[1].row,
                column2: wall.cells[1].column));
            break;
          }
      }
      cell = neighbour;
    }
    mazeBloc?.add(DoneEvent());
  }
}

class Cell {
  final int row, column;
  final Wall wallUp, wallDown, wallLeft, wallRight;
  bool isVisited;
  bool isUseful;

  Cell(
      {required this.row,
      required this.column,
      required this.wallUp,
      required this.wallDown,
      required this.wallLeft,
      required this.wallRight,
      this.isUseful = true,
      this.isVisited = false}) {
    wallUp.cells.add(this);
    wallDown.cells.add(this);
    wallLeft.cells.add(this);
    wallRight.cells.add(this);
  }

  List<Cell> get usefulSimplyConnectedNeighbors {
    List<Cell> neighbours = [];

    walls.forEach(
      (Wall wall) => wall.cells.forEach(
        (Cell cell) {
          if (cell != this && !wall.isWall && cell.isUseful)
            neighbours.add(cell);
        },
      ),
    );

    return neighbours;
  }

  List<Cell> get neighbours {
    List<Cell> neighbours = [];

    walls.forEach((Wall wall) => wall.cells.forEach((Cell cell) {
          if (cell != this) neighbours.add(cell);
        }));

    return neighbours;
  }

  List<Wall> get walls => [wallUp, wallDown, wallLeft, wallRight];

  List<Directions> get onWalls {
    List<Directions> walls = [];

    if (wallUp.isWall) walls.add(Directions.UP);
    if (wallDown.isWall) walls.add(Directions.DOWN);
    if (wallLeft.isWall) walls.add(Directions.LEFT);
    if (wallRight.isWall) walls.add(Directions.RIGHT);

    return walls;
  }
}

class Wall {
  bool isWall;
  List<Cell> cells = [];

  Wall({this.isWall = true});
}
