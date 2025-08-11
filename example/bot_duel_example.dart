import 'package:conway_lib/conway.dart';
import 'package:conway_lib/src/bot/mcts/mcts_node.dart';

void main() {
  Game game = new RandomGame(numberOfPlayers: 2, width: 5,
      height: 5, fractionLivingCells: 0.65, fractionDeadCells: 0.25);
  RandomBot randomBot = new RandomBot(game);
  MctsBot mctsBot = new MctsBot(game);
  do {
    print('Player #${game.currentPlayerId}');
    print('Board:\n${game.board.visualize()}');
    if (game.currentPlayerId == 0) {
      mctsBot.iterate(maxNumberOfIterations: 10000);
      List<MctsNode> rankedNodes = mctsBot.getRankedNodes();
      print(rankedNodes
          .map((e) => [e.toggledCellID, e.nVisits, e.score])
          .toList());
      int sum = 0;
      rankedNodes.forEach((element) {
        sum += element.nVisits;
      });
      print(sum);
    }
    int move = game.currentPlayerId == 0 ? mctsBot.play() : randomBot.play();
    print('Move: $move\n');
  } while(!game.gameOver);
  if(game.winner == null) {
    print('Draw');
  } else {
    print('Winner: ${game.winner}');
  }
}
