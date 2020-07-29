import 'package:conway/conway.dart';
import 'package:test/test.dart';

import '../game/test_game.dart';

void main() {

  Game _game;
  Bot _bot;

  group('Test RandomBot', () {
    setUp(() async {
      _game = new TestGame.TwoPlayers();
      _bot = new RandomBot(_game);
    });
    test('RandomBot is able to play a Game', () {
      expect(_game.currentPlayer, 0);
      expect(() => _bot.play(), isNot(throwsException));
      expect(_game.currentPlayer, _game.gameOver ? 0 : 1);
    });
  });
}
