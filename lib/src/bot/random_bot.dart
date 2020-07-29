import 'dart:math';

import 'bot.dart';
import '../game/game.dart';

class RandomBot extends Bot {

  Random _rng;

  RandomBot(Game game) : super(game) {
    _rng = new Random(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  int play() {
    List<int> possibleMoves = game.getPossibleMoves();
    int randomMove = possibleMoves[_rng.nextInt(possibleMoves.length)];
    game.toggleCell(randomMove);
    return randomMove;
  }
}
