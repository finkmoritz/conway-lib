/**
 * Small helper class that contains the result of a particular playout:
 * - gameOver: True, if the game ended during the playout
 * - winner: Index of the winning player
 * - survivedTurns: Number of turns in which the current player survived
 */
class PlayoutResult {
  PlayoutResult({this.gameOver, this.winner, this.survivedTurns});

  final bool gameOver;
  final int winner;
  final int survivedTurns;
}
