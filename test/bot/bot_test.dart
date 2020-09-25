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
    test('MctsBot is able to play a Game', () {
      _game = new TestGame.TwoPlayers();
      _mctsBot = new MctsBot(_game, maxPlayoutDepth: 10);
      expect(_game.currentPlayer, 0);
      expect(() => _mctsBot.play(maxDuration: Duration(seconds: 1)),
          isNot(throwsException));
      expect(_game.currentPlayer, _game.gameOver ? 0 : 1);
    });
    test('MctsBot always finds instantly winning move', () {
      for (int i = 0; i < 50; i++) {
        _game = new TestGame.TwoPlayersInstantWin();
        _mctsBot = new MctsBot(_game, maxPlayoutDepth: 10);
        int move = _mctsBot.play(maxNumberOfIterations: 100);
        bool isWinningMove = [1, 5, 6].contains(move);
        if (!isWinningMove) {
          print('MctsBot played non-winning move: $move !');
        }
        expect(isWinningMove, true);
        expect(_game.gameOver, true);
        expect(_game.winner, 0);
      }
    });
  });
}
