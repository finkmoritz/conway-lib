import 'package:conway_lib/conway.dart';

void main() {
  Game game = new RandomGame(numberOfPlayers: 2, width: 4,
      height: 4, fractionLivingCells: 0.6, fractionDeadCells: 0.25);
  Bot bot = new MctsBot(game);
  do {
    print('Player #${game.currentPlayerId}');
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
