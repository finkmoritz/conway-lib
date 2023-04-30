import 'dart:math';

import '../game/game.dart';
import 'bot.dart';

/**
 * Bot that plays random moves
 */
class SimpleBot extends Bot {
  late Random _rng;

  SimpleBot(Game game) : super(game) {
    _rng = new Random(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  int play() {
    int move = getRankedMoves()[0];
    game.toggleCell(move);
    game.endTurn();
    return move;
  }

  @override
  List<int> getRankedMoves() {
    List<int> reasonableMoves = game.getReasonableMoves();
    Map<int, double> scores = new Map();
    reasonableMoves.forEach((move) {
      Game g = game.clone();
      g.toggleCell(move);
      g.endTurn();
      scores[move] = _getScore(g);
    });
    reasonableMoves.shuffle(_rng);
    reasonableMoves.sort((a, b) {
      return ((scores[b]! - scores[a]!) * 1000).floor();
    });
    return reasonableMoves;
  }

  double _getScore(Game g) {
    int livingCellsOfPlayer =
        g.board.getLivingCellsOfPlayer(game.currentPlayerId).length;
    int livingCells = g.board.getLivingCells().length;
    if (livingCells == 0) {
      return 1.0 /
          game.numberOfPlayers; // because draw should be considered if enemies take over
    }
    return livingCellsOfPlayer.toDouble() / livingCells.toDouble();
  }
}
