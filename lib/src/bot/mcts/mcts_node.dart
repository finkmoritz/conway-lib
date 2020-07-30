import 'dart:math';

/**
 * Represents one node in the MCTS search tree
 */
class MctsNode {

  int playerID;
  int toggledCellID;
  double nWins = 0.0;
  int nVisits = 0;

  MctsNode parentNode;
  List<MctsNode> childNodes = [];

  MctsNode({this.parentNode, this.playerID, this.toggledCellID});

  double getExplorationScore() {
    double exploitation = nWins / nVisits;
    double exploration = sqrt(2 * log(parentNode.nVisits) / nVisits);
    return exploitation + exploration;
  }
}
