import '../exception/ConwayException.dart';
import 'cellState.dart';

/**
 * A Cell can be in one of the CellStates VOID, ALIVE or DEAD.
 * It is occupied by a player if and only if it is ALIVE.
 */
class Cell {

  CellState _state;
  int _playerID;

  Cell(this._state);

  get state => _state;
  get playerID => _playerID;

  revive(int playerID) {
    if(_state == CellState.VOID) {
      throw new ConwayException('Cell in state CellState.VOID cannot be revived');
    }
    _state = CellState.ALIVE;
    _playerID = playerID;
  }

  kill() {
    if(_state == CellState.VOID) {
      throw new ConwayException('Cell in state CellState.VOID cannot be killed');
    }
    _state = CellState.DEAD;
    _playerID = null;
  }
}
