import '../cell/cell.dart';
import '../cell/cell_state.dart';

/**
 * The Board class provides a collection of Cells
 */
class Board {

  final int _width;
  final int _height;
  late List<Cell> _cells;

  Board(this._width, this._height) {
    _cells = new List.generate(_width * _height, (i) => new Cell.Void());
  }

  int get width => _width;
  int get height => _height;
  int get numberOfCells => _width * _height;

  getCell(int i) => _cells[i];
  getCellByCoordinates(int x, int y) => _cells[y * _width + x];
  setCell(int i, Cell cell) => _cells[i] = cell;
  setCellByCoordinates(int x, int y, Cell cell) => _cells[y * _width + x] = cell;

  List<Cell> getLivingCells() {
    return _cells.where((cell) => cell.state == CellState.ALIVE).toList();
  }

  List<Cell> getLivingCellsOfPlayer(int playerID) {
    return _cells.where(
            (cell) => cell.state == CellState.ALIVE && cell.playerID == playerID)
        .toList();
  }

  List<Cell> getNeighbours(int index) {
    List<Cell> neighbours = [];
    getNeighbourIndices(index).forEach((nbrIndex) {
      neighbours.add(getCell(nbrIndex));
    });
    return neighbours;
  }

  List<int> getNeighbourIndices(int index) {
    List<int> neighbourIndices = [];
    [-1, 0, 1].forEach((dy) {
      [-1, 0, 1].forEach((dx) {
        if (dx != 0 || dy != 0) {
          int? i = getNeighbourIndex(index, dx, dy);
          if (i != null) {
            neighbourIndices.add(i);
          }
        }
      });
    });
    return neighbourIndices;
  }

  Cell? getNeighbour(int index, int dx, int dy) {
    int? i = getNeighbourIndex(index, dx, dy);
    return i == null ? null : getCell(i);
  }

  int? getNeighbourIndex(int index, int dx, int dy) {
    int x = index % width + dx;
    int y = (index / width + dy).floor();
    if (x >= 0 && x < width && y >= 0 && y < height) {
      return y * width + x;
    }
    return null;
  }

  Board clone() {
    Board boardClone = new Board(_width, _height);
    for (int i = 0; i < _cells.length; i++) {
      boardClone.setCell(i, getCell(i).clone());
    }
    return boardClone;
  }

  @override
  bool operator ==(Object other) {
    if(!(other is Board)) {
      return false;
    }
    if(this.width != other.width || this.height != other.height) {
      return false;
    }
    for(int i=0; i<this._cells.length; i++) {
      if(this.getCell(i) != other.getCell(i)) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    String boardString = 'Board{width:$_width,height:$_height,cells:[';
    _cells.forEach((cell) { boardString += '${cell.toString()},'; });
    boardString = boardString.substring(0, boardString.length -2);
    boardString += ']}';
    return boardString;
  }

  String visualize() {
    String s = '';
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        Cell cell = _cells[y * _width + x];
        switch(cell.state) {
          case CellState.ALIVE:
            s += '${cell.playerID}';
            break;
          case CellState.DEAD:
            s += 'x';
            break;
          default:
            s += ' ';
            break;
        }
      }
      s += '\n';
    }
    return s;
  }
}
