import 'package:conway/conway.dart';

void main() {
  int mctsWins = 0;
  int draws = 0;
  int randomWins = 0;
  int iterations = 1000;

  for(int i=0; i<iterations; i++) {
    print('Iteration ${i+1} of $iterations:');
    Game game = new RandomGame(numberOfPlayers: 2, width: 5,
        height: 5, fractionLivingCells: 0.65, fractionDeadCells: 0.25);
    RandomBot randomBot = new RandomBot(game);
    MctsBot mctsBot = new MctsBot(game, maxPlayoutDepth: 50);
    do {
      if(game.currentPlayer == 0) {
        mctsBot.play(numberOfIterations: 25000);
      } else {
        randomBot.play();
      }
    } while (!game.gameOver);
    if (game.winner == null) {
      draws++;
    } else {
      game.winner == 0 ? mctsWins++ : randomWins++;
    }
    print('MCTS / Draw / Random: $mctsWins / $draws / $randomWins');
  }
}
