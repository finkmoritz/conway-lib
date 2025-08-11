import 'package:conway_lib/conway.dart';
import 'package:test/test.dart';

import 'test_game.dart';

void main() {
  
  late Game _game;

  group('Test single player game', () {
    setUp(() async {
      _game = new TestGame.SinglePlayer();
    });
    test('toggleCell', () {
      _game.toggleCell(18);
      _game.endTurn();
      expect(_game.board, new TestGame.SinglePlayerAfterToggleCell18().board);
      expect(_game.currentPlayerId, 0);
      expect(_game.gameOver, false);
      expect(_game.winner, null);
    });
    test('getPossibleMoves', () {
      List<int> possibleMoves = _game.getPossibleMoves();
      expect(possibleMoves.length, 21);
      expect(possibleMoves, [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        9,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        23,
        24
      ]);
    });
    test('getReasonableMoves', () {
      _game = new TestGame.SinglePlayerSparse();
      List<int> reasonableMoves = _game.getReasonableMoves();
      expect(reasonableMoves.length, 18);
    });
  });
  
  group('Test two player game', () {
    setUp(() async {
      _game = new TestGame.TwoPlayers();
    });
    test('toggleCell', () {
      _game.toggleCell(0);
      expect(_game.toggledCellId, 0);
      _game.endTurn();
      expect(_game.board, new TestGame.TwoPlayersAfterToggleCell0().board);
      expect(_game.currentPlayerId, 1);
      expect(_game.gameOver, false);
      expect(_game.winner, null);
    });
    test('toggle same cell', () {
      _game.toggleCell(0);
      expect(_game.toggledCellId, 0);
      _game.toggleCell(0);
      expect(_game.toggledCellId, null);
      expect(() => _game.endTurn(), throwsException);
    });
    test('toggle another cell', () {
      _game.toggleCell(24);
      expect(_game.toggledCellId, 24);
      _game.toggleCell(0);
      expect(_game.toggledCellId, 0);
      expect(() => _game.endTurn(), isNot(throwsException));
      expect(_game.lastToggledCellId, 0);
      expect(_game.toggledCellId, null);
      expect(_game.board, new TestGame.TwoPlayersAfterToggleCell0().board);
    });
    test('getPossibleMoves', () {
      List<int> possibleMoves = _game.getPossibleMoves();
      expect(possibleMoves.length, 22);
      expect(possibleMoves, [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        9,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        23,
        24
      ]);
    });
  });

  group('Test game over', () {
    setUp(() async {
      _game = new TestGame.TwoPlayersAfterToggleCell0();
    });
    test('Test game over', () {
      expect(_game.gameOver, false);
      _game.toggleCell(2);
      expect(_game.gameOver, false);
      _game.endTurn();
      expect(_game.gameOver, true);
    });
  });

  group('Test sudden death', () {
    setUp(() async {
      _game = new TestGame.TwoPlayers(roundsBeforeSuddenDeath: 1);
    });
    test('Test sudden death', () {
      expect(_game.round, 1);
      expect(_game.getPossibleMoves().length, 22);
      _game.toggleCell(0);
      _game.endTurn();
      expect(_game.getPossibleMoves().length, 22);
      _game.toggleCell(19);
      _game.endTurn();
      expect(_game.round, 2);
      expect(_game.getPossibleMoves().length, 21);
    });
  });
}
