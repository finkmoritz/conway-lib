import 'package:conway/conway.dart';

void main() {
  Game game = new RandomGame(numberOfPlayers: 2, width: 5,
      height: 5, fractionLivingCells: 0.65, fractionDeadCells: 0.25);
  RandomBot randomBot = new RandomBot(game);
  MctsBot mctsBot = new MctsBot(game);
  do {
    print('Player #${game.currentPlayer}');
    print('Board:\n${game.board.visualize()}');
    int move = game.currentPlayer == 0 ? mctsBot.play() : randomBot.play();
    print('Move: $move\n');
  } while(!game.gameOver);
  if(game.winner == null) {
    print('Draw');
  } else {
    print('Winner: ${game.winner}');
  }
}
