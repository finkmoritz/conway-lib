import '../cell/cell.dart';

/**
 * The Board class provides a collection of Cells
 */
class Board {

  int _width;
  int _height;
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
}
