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
    game.endTurn();
    return randomMove;
  }

  @override
  List<int> getRankedMoves() {
    List<int> reasonableMoves = game.getReasonableMoves();
    reasonableMoves.shuffle(_rng);
    return reasonableMoves;
  }
}
