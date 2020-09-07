import 'dart:math';

import '../exception/conway_exception.dart';
import '../cell/cell_state.dart';
import '../cell/cell.dart';
import '../board/board.dart';

/**
 * The Game class holds any information the user needs for playing
 * a game of Conway
 */
class Game {

  Board _board;
  int _numberOfPlayers;
  int _currentPlayer = 0;
  bool _gameOver = false;
  int _winner;

  Game({numberOfPlayers = 2, width = 5, height = 5}) {
    _numberOfPlayers = numberOfPlayers;
    _board = new Board(width, height);
  }

  get board => _board;

  get numberOfPlayers => _numberOfPlayers;

  /**
   * Returns the ID of the current Player.
   */
  get currentPlayer => _currentPlayer;

  /**
   * Returns true if and only if at most one PLayer's Cells survived.
   */
  get gameOver => _gameOver;

  /**
   * Returns the winning Player's ID if and only if gameOver is true and
   * only one Player's Cells survived.
   */
  get winner => _winner;

  /**
   * Returns a list of valid indices for the toggleCell method
   */
  List<int> getPossibleMoves() {
    List<int> indices = [];
    if(gameOver) {
      return indices;
    }
    for(int i=0; i<board.numberOfCells; i++) {
      if([CellState.ALIVE, CellState.DEAD].contains(board.getCell(i).state)) {
        indices.add(i);
      }
    }
    return indices;
  }

  /**
   * toggleCell is the only move in a Conway Game
   */
  toggleCell(int i) {
    if(_gameOver) {
      throw new ConwayException('Cannot toggle the Cell because the Game is over');
    }
    Cell cell = _board.getCell(i);
    switch(cell.state) {
      case CellState.ALIVE:
        cell.kill();
        break;
      case CellState.DEAD:
        cell.revive(_currentPlayer);
        break;
      default:
        throw new ConwayException('Cannot toggle Cell in state ${cell.state}');
        break;
    }
    _endTurn();
  }

  /**
   * see toggleCell method
   */
  toggleCellByCoordinates(int x, int y) {
    toggleCell(y * _board.width + x);
  }

  _endTurn() {
    _iterate();
    _checkGameOver();
    if(!gameOver) {
      do {
        _currentPlayer = (_currentPlayer + 1) % _numberOfPlayers;
      } while(board.getLivingCellsOfPlayer(_currentPlayer).isEmpty);
    }
  }

  _iterate() {
    Board result = _board.clone();
    int nCells = _board.width * _board.height;
    for(int i=0; i<nCells; i++) {
      List<Cell> neighbours = _board.getNeighbours(i);
      int nNeighboursAlive = neighbours.where(
              (cell) => cell.state == CellState.ALIVE
      ).toList().length;
      CellState state = _board.getCell(i).state;
      if(state == CellState.DEAD && nNeighboursAlive == 3) {
        int dominantPlayer = _computeDominantPlayer(neighbours);
        result.getCell(i).revive(dominantPlayer);
      } else if(state == CellState.ALIVE && (nNeighboursAlive < 2 || nNeighboursAlive > 3)) {
        result.getCell(i).kill();
      }
    }
    _board = result;
  }

  int _computeDominantPlayer(List<Cell> neighbours) {
    List<List<int>> playerCount = List.generate(_numberOfPlayers, (playerID) => [playerID, 0]);
    neighbours.forEach((cell) {
      if(cell.playerID != null) {
        playerCount[cell.playerID][1]++;
      }
    });
    playerCount.sort((a, b) { return a[1] - b[1]; });
    int maxCount = playerCount[_numberOfPlayers - 1][1];
    while(playerCount[0][1] < maxCount) {
      playerCount = playerCount.sublist(1);
    }
    List<int> dominantPlayers = List.generate(playerCount.length, (i) => playerCount[i][0]);
    if(dominantPlayers.length == 1) {
      return dominantPlayers[0];
    } else {
      if(dominantPlayers.contains(_currentPlayer)) {
        return _currentPlayer;
      } else {
        int random = (new Random()).nextInt(dominantPlayers.length);
        return dominantPlayers[random];
      }
    }
  }

  _checkGameOver() {
    List<Cell> livingCells = _board.getLivingCells();
    if(livingCells.isEmpty) {
      _gameOver = true;
    } else {
      if(numberOfPlayers == 1) {
        return;
      }
      int livingPlayer = livingCells[0].playerID;
      for(int i=1; i<livingCells.length; i++) {
        if(livingCells[i].playerID != livingPlayer) {
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
    clone._currentPlayer = this.currentPlayer;
    clone._gameOver = this.gameOver;
    clone._winner = this.winner;
    return clone;
  }

  @override
  bool operator ==(other) {
    return this.board == other.board
        && this.numberOfPlayers == other.numberOfPlayers
        && this.currentPlayer == other.currentPlayer
        && this.gameOver == other.gameOver
        && this.winner == other.winner;
  }

  @override
  String toString() {
    String gameString = 'Game{board:${_board.toString()}';
    return gameString;
  }
}
