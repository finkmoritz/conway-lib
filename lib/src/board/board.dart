import '../cell/cell.dart';
import '../cell/cell_state.dart';

/**
 * The Board class provides a collection of Cells
 */
class Board {

  final int _width;
  final int _height;
  List<Cell> _cells;

  Board(this._width, this._height) {
    _cells = new List.generate(_width * _height, (i) => new Cell.Void());
  }

  get width => _width;
  get height => _height;
  get numberOfCells => _width * _height;

  getCell(int i) => _cells[i];
  getCellByCoordinates(int x, int y) => _cells[y * _width + x];
  setCell(int i, Cell cell) => _cells[i] = cell;
  setCellByCoordinates(int x, int y, Cell cell) => _cells[y * _width + x] = cell;

  List<Cell> getLivingCells() {
    return _cells.where((cell) => cell.state == CellState.ALIVE).toList();
  }

  List<Cell> getNeighbours(int index) {
    List<Cell> neighbours = [];
    [-1, 0, 1].forEach((dy) {
      [-1, 0, 1].forEach((dx) {
        if(dx != 0 || dy != 0) {
          Cell neighbour = getNeighbour(index, dx, dy);
          if(neighbour != null) {
            neighbours.add(neighbour);
          }
        }
      });
    });
    return neighbours;
  }

  Cell getNeighbour(int index, int dx, int dy) {
    int x = index % width + dx;
    int y = (index / width + dy).floor();
    if(x >= 0 && x < width && y >= 0 && y < height) {
      return getCellByCoordinates(x, y);
    }
    return null;
  }

  Board clone() {
    Board boardClone = new Board(_width, _height);
    for(int i=0; i<_cells.length; i++) {
      boardClone.setCell(i, getCell(i).clone());
    }
    return boardClone;
  }

  @override
  bool operator ==(other) {
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
}
