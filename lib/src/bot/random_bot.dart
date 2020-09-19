import 'dart:math';

import '../game/game.dart';
import 'bot.dart';

/**
 * Bot that plays random moves
 */
class RandomBot extends Bot {

  Random _rng;

  RandomBot(Game game) : super(game) {
    _rng = new Random(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  int play() {
    List<int> reasonableMoves = game.getReasonableMoves();
    int randomMove = reasonableMoves[_rng.nextInt(reasonableMoves.length)];
    game.toggleCell(randomMove);
    return randomMove;
  }
}
