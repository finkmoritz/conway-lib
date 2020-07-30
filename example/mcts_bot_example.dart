import 'package:conway/conway.dart';

void main() {
  RandomGame game = new RandomGame(numberOfPlayers: 2, width: 4,
      height: 4, fractionLivingCells: 0.6, fractionDeadCells: 0.25);
  MctsBot bot = new MctsBot(game);
  do {
    int move = bot.play();
    print('Move: $move');
  } while(!game.gameOver);
  if(game.winner == null) {
    print('Draw');
  } else {
    print('Winner: ${game.winner}');
  }
}
