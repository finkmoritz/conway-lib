import 'package:conway/conway.dart';

void main() {
  Game game = new RandomGame(numberOfPlayers: 2, width: 8,
      height: 8, fractionLivingCells: 0.6, fractionDeadCells: 0.25);
  Bot bot = new RandomBot(game);
  do {
    print('Player #${game.currentPlayer}');
    print('Board:\n${game.board.visualize()}');
    int move = bot.play();
    print('Move: $move\n');
  } while(!game.gameOver);
  if(game.winner == null) {
    print('Draw');
  } else {
    print('Winner: ${game.winner}');
  }
}
