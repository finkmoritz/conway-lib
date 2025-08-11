import 'dart:math';

import '../board/board.dart';
import '../cell/cell.dart';
import '../cell/cell_state.dart';
import '../exception/conway_exception.dart';

/**
 * The Game class holds any information the user needs for playing
 * a game of Conway.
 */
class Game {
  late Board _board;
  late int _numberOfPlayers;
  int _currentPlayerId = 0;
  int? _toggledCellId;
  int? _lastToggledCellId;
  int? _toggledCellPlayerId;
  bool _gameOver = false;
  int? _winner;
  int _round = 1;
  int? _roundsBeforeSuddenDeath;
  late Random _rng;

  Game({numberOfPlayers = 2, width = 5, height = 5, roundsBeforeSuddenDeath}) {
    _numberOfPlayers = numberOfPlayers;
    _board = new Board(width, height);
    _roundsBeforeSuddenDeath = roundsBeforeSuddenDeath;
    _rng = new Random(DateTime.now().millisecondsSinceEpoch);
  }

  Board get board => _board;

  int get numberOfPlayers => _numberOfPlayers;

  /**
   * Returns the ID of the current Player.
   */
  int get currentPlayerId => _currentPlayerId;

  /**
   * Return the ID of the currently toggled cell.
   * Returns null if no cell is toggled.
   */
  int? get toggledCellId => _toggledCellId;

  /**
   * Returns the ID of the cell that has been toggled during the last turn.
   */
  int? get lastToggledCellId => _lastToggledCellId;

  /**
   * Returns true if and only if at most one PLayer's Cells survived.
   */
  bool get gameOver => _gameOver;

  /**
   * Returns the winning Player's ID if and only if gameOver is true and
   * only one Player's Cells survived.
   */
  int? get winner => _winner;

  /**
   * Returns the current round number (starting at 1).
   * This number is increased at the beginning of each new round of the game.
   */
  int get round => _round;

  /**
   * Returns the number of rounds before the sudden death mechanism is triggered
   * or null if no sudden death was configured.
   */
  int? get roundsBeforeSuddenDeath => _roundsBeforeSuddenDeath;

  /**
   * toggleCell is the only move in a Conway Game.
   */
  toggleCell(int i) {
    if (_gameOver) {
      throw new ConwayException(
          'Cannot toggle the Cell because the Game is over');
    }
    if (i == _toggledCellId) {
      _toggledCellId = null;
    } else {
      if (_toggledCellId != null) {
        _toggleCellInternal(_toggledCellId!);
      }
      _toggledCellId = i;
    }
    _toggleCellInternal(i);
  }

  _toggleCellInternal(int i) {
    Cell cell = _board.getCell(i);
    switch (cell.state) {
      case CellState.ALIVE:
        _toggledCellPlayerId = cell.playerID;
        cell.kill();
        break;
      case CellState.DEAD:
        cell.revive(_toggledCellPlayerId ?? _currentPlayerId);
        _toggledCellPlayerId = null;
        break;
      default:
        throw new ConwayException('Cannot toggle Cell in state ${cell.state}');
    }
  }

  /**
   * see toggleCell method.
   */
  toggleCellByCoordinates(int x, int y) {
    toggleCell(y * _board.width + x);
  }

  /**
   * endTurn ends the turn, i.e. it applies the rules of Conway's
   * Game of Life and sets the game over state if applicable.
   */
  endTurn() {
    if (_toggledCellId == null) {
      throw new ConwayException('Cannot end turn if no cell is toggled');
    }
    _iterate();

    _lastToggledCellId = _toggledCellId;
    _toggledCellId = null;
    _toggledCellPlayerId = null;

    _checkGameOver();
    if (!gameOver) {
      do {
        _currentPlayerId = (_currentPlayerId + 1) % _numberOfPlayers;
        if (_currentPlayerId == 0) {
          _round++;
          _suddenDeath();
        }
      } while (board.getLivingCellsOfPlayer(_currentPlayerId).isEmpty);
    }
  }

  /**
   * Returns a list of valid indices for the toggleCell method
   */
  List<int> getPossibleMoves() {
    if (gameOver) {
      return [];
    }
    List<int> possibleMoves = [];
    for (int i = 0; i < board.numberOfCells; i++) {
      if ([CellState.ALIVE, CellState.DEAD].contains(board.getCell(i).state)) {
        possibleMoves.add(i);
      }
    }
    return possibleMoves;
  }

  /**
   * Returns a list of reasonable indices for the toggleCell method.
   * This method returns a subset of the moves returned by getPossibleMoves,
   * but with all moves that do not impact the next
   * board state directly summarized into one 'idle' move.
   * Moves without impact are cells that only have non-living neighbours with
   * in turn non-living neighbours.
   */
  List<int> getReasonableMoves() {
    if (gameOver) {
      return [];
    }
    List<int> numberOfNeighbours = [];
    for (int i = 0; i < board.numberOfCells; i++) {
      int nNeighboursAlive = _board
          .getNeighbours(i)
          .where((cell) => cell.state == CellState.ALIVE)
          .toList()
          .length;
      numberOfNeighbours.add(nNeighboursAlive);
    }
    List<int> idleMoves = [];
    for (int i = 0; i < board.numberOfCells; i++) {
      if (_board.getCell(i).state != CellState.VOID &&
          numberOfNeighbours[i] == 0) {
        List<int> neighbourIndices = board.getNeighbourIndices(i);
        if (neighbourIndices
            .where((nbrIndex) => numberOfNeighbours[nbrIndex] != 0)
            .isEmpty) {
          idleMoves.add(i);
        }
      }
    }
    List<int> reasonableMoves = getPossibleMoves();
    if (idleMoves.length > 1) {
      reasonableMoves.removeWhere((move) => idleMoves.contains(move));
      idleMoves.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
      reasonableMoves.add(idleMoves.first);
    }
    return reasonableMoves;
  }

  _suddenDeath() {
    if (_roundsBeforeSuddenDeath != null &&
        _round > _roundsBeforeSuddenDeath!) {
      int n = _round - _roundsBeforeSuddenDeath!;
      List<int> nonVoidCells = getPossibleMoves();
      nonVoidCells.shuffle(_rng);
      nonVoidCells.take(n).forEach((i) {
        board.setCell(i, new Cell.Void());
      });
      _checkGameOver();
    }
  }

  _iterate() {
    Board result = _board.clone();
    int nCells = _board.width * _board.height;
    for (int i = 0; i < nCells; i++) {
      List<Cell> neighbours = _board.getNeighbours(i);
      int nNeighboursAlive = neighbours
          .where((cell) => cell.state == CellState.ALIVE)
          .toList()
          .length;
      CellState state = _board.getCell(i).state;
      if (state == CellState.DEAD && nNeighboursAlive == 3) {
        int dominantPlayer = _computeDominantPlayer(neighbours);
        result.getCell(i).revive(dominantPlayer);
      } else if (state == CellState.ALIVE &&
          (nNeighboursAlive < 2 || nNeighboursAlive > 3)) {
        result.getCell(i).kill();
      }
    }
    _board = result;
  }

  int _computeDominantPlayer(List<Cell> neighbours) {
    List<List<int>> playerCount =
        List.generate(_numberOfPlayers, (playerID) => [playerID, 0]);
    neighbours.forEach((cell) {
      if (cell.playerID != null) {
        playerCount[cell.playerID!][1]++;
      }
    });
    playerCount.sort((a, b) {
      return a[1] - b[1];
    });
    int maxCount = playerCount[_numberOfPlayers - 1][1];
    while (playerCount[0][1] < maxCount) {
      playerCount = playerCount.sublist(1);
    }
    List<int> dominantPlayers =
        List.generate(playerCount.length, (i) => playerCount[i][0]);
    if (dominantPlayers.length == 1) {
      return dominantPlayers[0];
    } else {
      if (dominantPlayers.contains(_currentPlayerId)) {
        return _currentPlayerId;
      } else {
        int random = (new Random()).nextInt(dominantPlayers.length);
        return dominantPlayers[random];
      }
    }
  }

  _checkGameOver() {
    List<Cell> livingCells = _board.getLivingCells();
    if (livingCells.isEmpty) {
      _gameOver = true;
    } else {
      if (numberOfPlayers == 1) {
        return;
      }
      int livingPlayer = livingCells[0].playerID!;
      for (int i = 1; i < livingCells.length; i++) {
        if (livingCells[i].playerID != livingPlayer) {
          return;
        }
      }
      _gameOver = true;
      _winner = livingPlayer;
    }
  }

  Game clone() {
    Game clone = new Game(numberOfPlayers: this.numberOfPlayers);
    clone._board = this.board.clone();
    clone._currentPlayerId = this.currentPlayerId;
    clone._toggledCellId = this.toggledCellId;
    clone._lastToggledCellId = this.lastToggledCellId;
    clone._toggledCellPlayerId = this._toggledCellPlayerId;
    clone._gameOver = this.gameOver;
    clone._winner = this.winner;
    clone._round = this.round;
    //TODO: left out, otherwise MctsBot breaks...
    //clone._roundsBeforeSuddenDeath = this.roundsBeforeSuddenDeath;
    return clone;
  }

  @override
  bool operator ==(Object other) {
    return other is Game &&
        this.board == other.board &&
        this.numberOfPlayers == other.numberOfPlayers &&
        this.currentPlayerId == other.currentPlayerId &&
        this.toggledCellId == other.toggledCellId &&
        this.lastToggledCellId == other.lastToggledCellId &&
        this.gameOver == other.gameOver &&
        this.winner == other.winner &&
        this.round == other.round;
    //TODO: left out because not included in clone()
    //&& this.roundsBeforeSuddenDeath == other.roundsBeforeSuddenDeath;
  }

  @override
  String toString() {
    String gameString = 'Game{board:${_board.toString()}';
    return gameString;
  }
}
