import 'package:conway/conway.dart';
import 'package:test/test.dart';

import '../game/test_game.dart';

void main() {

  Game _game;
  RandomBot _randomBot;
  MctsBot _mctsBot;

  group('Test RandomBot', () {
    setUp(() async {
      _game = new TestGame.TwoPlayers();
      _randomBot = new RandomBot(_game);
    });
    test('RandomBot is able to play a Game', () {
      expect(_game.currentPlayer, 0);
      expect(() => _randomBot.play(), isNot(throwsException));
      expect(_game.currentPlayer, _game.gameOver ? 0 : 1);
    });
  });

  group('Test MctsBot', () {
    setUp(() async {
      _game = new TestGame.TwoPlayers();
      _mctsBot = new MctsBot(_game, maxPlayoutDepth: 10);
    });
    test('MctsBot is able to play a Game', () {
      expect(_game.currentPlayer, 0);
      expect(() => _mctsBot.play(), isNot(throwsException));
      expect(_game.currentPlayer, _game.gameOver ? 0 : 1);
    });
  });
}
