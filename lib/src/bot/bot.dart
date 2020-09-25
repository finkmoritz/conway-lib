import '../game/game.dart';

/**
 * A class implementing the Bot interface should be able to play a Conway Game
 * on its own.
 */
abstract class Bot {

  Game game;

  Bot(this.game);

  /**
   * Makes a move on the Game and returns the index of the toggled Cell.
   */
  int play();

  /**
   * Returns a list of moves, ordered by their score
   */
  List<int> getRankedMoves();
}
