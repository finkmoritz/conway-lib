import 'package:conway/conway.dart';

void main() {
  RandomGame game = new RandomGame(numberOfPlayers: 2, width: 8,
      height: 8, fractionLivingCells: 0.6, fractionDeadCells: 0.25);
  RandomBot bot = new RandomBot(game);
  do {
    bot.play();
  } while(!game.gameOver);
  if(game.winner == null) {
    print('Draw');
  } else {
    print('Winner: ${game.winner}');
  }
}
