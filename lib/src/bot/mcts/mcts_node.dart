import 'dart:math';

/**
 * Represents one node in the MCTS search tree
 */
class MctsNode {

  int toggledCellID;
  double score = 0.0;
  int nVisits = 0;

  MctsNode parentNode;
  List<MctsNode> childNodes = [];

  MctsNode({this.parentNode, this.toggledCellID});

  bool get isLeaf => childNodes.isEmpty;

  double getExplorationScore() {
    double exploitation = score / nVisits;
    double exploration = sqrt(0.5 * log(parentNode.nVisits) / nVisits);
    return exploitation + exploration;
  }
}
