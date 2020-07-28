import 'package:conway/conway.dart';
import 'package:test/test.dart';

import 'test_game.dart';

void main() {
  
  Game _game;
  
  group('Test two player game', () {
    setUp(() async {
      _game = new TestGame.TwoPlayers();
    });
    test('Toggle cell', () {
      _game.toggleCell(0);
      expect(_game.board, new TestGame.TwoPlayersAfterToggleCell0().board);
      expect(_game.currentPlayer, 1);
      expect(_game.gameOver, false);
      expect(_game.winner, null);
    });
  });
}
