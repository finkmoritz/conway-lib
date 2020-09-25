import 'package:conway/conway.dart';
import 'package:conway/src/bot/simple_bot.dart';

void main() {
  int mctsWins = 0;
  int draws = 0;
  int otherWins = 0;
  int iterations = 1000;

  for (int i = 0; i < iterations; i++) {
    print('Iteration ${i + 1} of $iterations:');
    Game game = new RandomGame(
        numberOfPlayers: 4,
        width: 10,
        height: 10,
        fractionLivingCells: 0.65,
        fractionDeadCells: 0.25);
    SimpleBot otherBot = new SimpleBot(game);
    MctsBot mctsBot = new MctsBot(game, maxPlayoutDepth: 10);
    do {
      if (game.currentPlayer == 0) {
        mctsBot.play(
            maxNumberOfIterations: 10000, maxDuration: Duration(seconds: 10));
      } else {
        otherBot.play();
      }
    } while (!game.gameOver);
    if (game.winner == null) {
      draws++;
    } else {
      game.winner == 0 ? mctsWins++ : otherWins++;
    }
    print('MCTS / Draw / Other: $mctsWins / $draws / $otherWins');
  }
}
