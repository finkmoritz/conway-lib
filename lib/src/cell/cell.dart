import '../exception/conway_exception.dart';
import 'cell_state.dart';

/**
 * A Cell can be in one of the CellStates VOID, ALIVE or DEAD.
 * It is occupied by a player if and only if it is ALIVE.
 */
class Cell {
  late CellState _state;
  int? _playerID;

  Cell.Void() {
    _state = CellState.VOID;
  }

  Cell.Alive(int playerID) {
    _state = CellState.ALIVE;
    _playerID = playerID;
  }

  Cell.Dead() {
    _state = CellState.DEAD;
  }

  get state => _state;

  get playerID => _playerID;

  revive(int playerID) {
    switch (_state) {
      case CellState.VOID:
        throw new ConwayException(
            'Cell in state CellState.VOID cannot be revived');
      case CellState.ALIVE:
        throw new ConwayException(
            'Cell in state CellState.ALIVE cannot be revived');
      default:
        _state = CellState.ALIVE;
        _playerID = playerID;
        break;
    }
  }

  kill() {
    switch (_state) {
      case CellState.VOID:
        throw new ConwayException(
            'Cell in state CellState.VOID cannot be killed');
      case CellState.DEAD:
        throw new ConwayException(
            'Cell in state CellState.DEAD cannot be killed');
      default:
        _state = CellState.DEAD;
        _playerID = null;
        break;
    }
  }

  Cell clone() {
    switch (_state) {
      case CellState.ALIVE:
        return new Cell.Alive(_playerID!);
      case CellState.DEAD:
        return new Cell.Dead();
      default:
        return new Cell.Void();
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Cell &&
        this.state == other.state &&
        this.playerID == other.playerID;
  }

  @override
  String toString() {
    return 'Cell{state:$state,playerID:$playerID}';
  }
}
