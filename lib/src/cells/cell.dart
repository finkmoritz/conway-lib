import 'cellState.dart';

class Cell {

  CellState _state;
  int _playerID;

  Cell(this._state);

  get state => _state;
  get playerID => _playerID;

  revive(int playerID) {
    _state = CellState.ALIVE;
    _playerID = playerID;
  }

  kill() {
    _state = CellState.DEAD;
    _playerID = null;
  }
}
