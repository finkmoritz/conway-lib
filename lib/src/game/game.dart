import 'dart:math';

import '../exception/conway_exception.dart';
import '../cell/cell_state.dart';
import '../cell/cell.dart';
import '../board/board.dart';
import 'game_config.dart';

class Game {

  final GameConfig _gameConfig;
  Board _board;
  int _currentPlayer = 0;

  Game(this._gameConfig) {
    _board = new Board(_gameConfig.boardWidth, _gameConfig.boardHeight);
  }

  get board => _board;
  get currentPlayer => _currentPlayer;

  toggleCell(int i) {
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
  toggleCellByCoordinates(int x, int y) {
    toggleCell(y * _board.width + x);
  }

  _endTurn() {
    _iterate();
    _currentPlayer = (_currentPlayer + 1) % _gameConfig.numberOfPlayers;
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
    int nPlayers = _gameConfig.numberOfPlayers;
    List<List<int>> playerCount = List.generate(nPlayers, (playerID) => [playerID, 0]);
    neighbours.forEach((cell) {
      if(cell.playerID != null) {
        playerCount[cell.playerID][1]++;
      }
    });
    playerCount.sort();
    int maxCount = playerCount[nPlayers - 1][1];
    while(playerCount[0][1] < maxCount) {
      playerCount.sublist(1);
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
}
