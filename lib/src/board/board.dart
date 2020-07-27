import '../cell/cell.dart';

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

  getCell(int i) => _cells[i];
  getCellByCoordinates(int x, int y) => _cells[y * _width + x];
  setCell(int i, Cell cell) => _cells[i] = cell;
  setCellByCoordinates(int x, int y, Cell cell) => _cells[y * _width + x] = cell;

  List<Cell> getNeighbours(int index) {
    List<Cell> neighbours = [];
    [-1, 0, 1].forEach((dx) {
      [-1, 0, 1].forEach((dy) {
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
    int x = index % 5 + dx;
    int y = (index / 5 + dy) as int;
    if(x >= 0 && x < 5 && y >= 0 && y < 5) {
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
}
