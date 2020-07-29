import 'package:conway/conway.dart';
import 'package:test/test.dart';

import 'test_game.dart';

void main() {
  
  Game _game;
  
  group('Test two player game', () {
    setUp(() async {
      _game = new TestGame.TwoPlayers();
    });
    test('toggleCell', () {
      _game.toggleCell(0);
      expect(_game.board, new TestGame.TwoPlayersAfterToggleCell0().board);
      expect(_game.currentPlayer, 1);
      expect(_game.gameOver, false);
      expect(_game.winner, null);
    });
    test('getPossibleMoves', () {
      List<int> possibleMoves = _game.getPossibleMoves();
      expect(possibleMoves.length, 22);
      expect(possibleMoves, [ 0,  1,  2,  3,  4,
                              5,  6,  7,      9,
                                 11, 12, 13, 14,
                             15, 16, 17, 18, 19,
                             20, 21,     23, 24]);
    });
  });
}
