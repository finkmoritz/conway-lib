import 'dart:math';

import 'package:conway/conway.dart';

void main() {
  RandomGame game = new RandomGame(numberOfPlayers: 2, width: 8,
      height: 8, fractionLivingCells: 0.6, fractionDeadCells: 0.25);
  Random rng = new Random(DateTime.now().millisecondsSinceEpoch);
  List<int> possibleMoves = game.getPossibleMoves();
  do {
    int randomIndex = rng.nextInt(possibleMoves.length);
    game.toggleCell(possibleMoves[randomIndex]);
  } while(!game.gameOver);
  if(game.winner == null) {
    print('Draw');
  } else {
    print('Winner: ${game.winner}');
  }
}
