import 'dart:math';

import 'package:conway/conway.dart';

import '../../game/game.dart';
import '../bot.dart';
import 'mcts_node.dart';

/**
 * Bot that uses a Monte Carlo Tree Search (MCTS) algorithm to find
 * a good move. The higher the number of iterations and the playout
 * depth the better moves it will find but also consume more time.
 */
class MctsBot extends Bot {

  Random _rng;
  MctsNode rootNode;

  MctsBot(Game game) : super(game) {
    _rng = new Random(DateTime.now().millisecondsSinceEpoch);
    _reset();
  }

  /**
   * Play a move by application of the MCTS algorithm. The node with
   * the highest number of visits is chosen to be the best move.
   */
  @override
  int play({int maxNumberOfIterations = 10000, Duration maxDuration}) {
    iterate(
        maxNumberOfIterations: maxNumberOfIterations, maxDuration: maxDuration);
    int move = getRankedMoves()[0];
    game.toggleCell(move);
    game.endTurn();
    return move;
  }

  /**
   * Apply the given number of iterations to develop the search tree.
   * Per default the search tree will be reset at each invocation of
   * this method. When reset=false, the tree will not be reset (only
   * use this option if the game state has not been changed in between
   * iterations!)
   */
  void iterate(
      {int maxNumberOfIterations = 1000,
      Duration maxDuration,
      bool reset = true}) {
    DateTime endTime = DateTime.now().add(maxDuration ?? Duration(days: 999));
    if (reset) {
      _reset();
    }
    int i = 0;
    while (i < maxNumberOfIterations && DateTime.now().isBefore(endTime)) {
      List<MctsNode> path = _selectNodeForPlayout(rootNode);
      MctsNode selectedNode = path.last;
      Game gameAtSelectedNode = _computeGameAfterPath(path);
      List<int> reasonableMoves = gameAtSelectedNode.getReasonableMoves();
      if (reasonableMoves.isEmpty) {
        if (++i > maxNumberOfIterations || DateTime.now().isAfter(endTime)) {
          return;
        }
        _backpropagate(selectedNode, _getScore(gameAtSelectedNode));
      } else {
        reasonableMoves.forEach((move) {
          if (++i > maxNumberOfIterations || DateTime.now().isAfter(endTime)) {
            return;
          }
          MctsNode newNode = _expand(selectedNode, move);
          double playoutScore = _playout(newNode, gameAtSelectedNode);
          _backpropagate(newNode, playoutScore);
        });
      }
    }
  }

  /**
   * Return a list of moves sorted by the number of visits on the respective node.
   * The first move in the list has the highest number of visits on the respective node.
   */
  @override
  List<int> getRankedMoves() {
    return getRankedNodes()
        .map((node) => node.toggledCellID)
        .toList();
  }

  /**
   * Return a list of MCTS nodes sorted by the number of visits.
   * The first node in the list has the highest number of visits.
   */
  List<MctsNode> getRankedNodes() {
    rootNode.childNodes.shuffle(_rng); //otherwise advantage for low indices
    rootNode.childNodes.sort((a, b) {
      if (_isInstantWin(a) || _isInstantWin(b)) {
        return (_isInstantWin(b) ? 1 : 0) - (_isInstantWin(a) ? 1 : 0);
      }
      return b.nVisits - a.nVisits;
    });
    return rootNode.childNodes;
  }

  bool _isInstantWin(MctsNode node) {
    return node.parentNode == rootNode &&
        node.isLeaf &&
        node.score >= node.nVisits;
  }

  /**
   * Resets the search tree.
   * Call this method at least after each change of the game state.
   */
  void _reset() {
    rootNode = new MctsNode();
  }

  /**
   * Selection according to UCT (Upper Confidence Bound 1),
   * originally introduced by Kocsis and Szepesvári.
   * Returns the full path of nodes from root to the selected node.
   */
  List<MctsNode> _selectNodeForPlayout(MctsNode rootNode) {
    List<MctsNode> path = [rootNode];
    MctsNode currentNode = path[0];
    while (!currentNode.isLeaf) {
      currentNode = _getNodeWithHighestExplorationScore(currentNode.childNodes);
      path.add(currentNode);
    }
    return path;
  }

  /**
   * Returns the node with the highest exploration score.
   * If multiple nodes have the same value, one of those will
   * be chosen at random.
   */
  MctsNode _getNodeWithHighestExplorationScore(List<MctsNode> nodes) {
    double maxScore = 0;
    List<MctsNode> bestNodes = [];
    nodes.forEach((node) {
      double explorationScore = node.getExplorationScore();
      if (explorationScore > maxScore) {
        maxScore = explorationScore;
        bestNodes = [node];
      } else if (explorationScore == maxScore) {
        bestNodes.add(node);
      }
    });
    return bestNodes[_rng.nextInt(bestNodes.length)];
  }

  /**
   * Compute the Game state after the given path of nodes.
   */
  Game _computeGameAfterPath(List<MctsNode> path) {
    Game gameClone = game.clone();
    for(int i=1; i<path.length; i++) {
      int move = path[i].toggledCellID;
      gameClone.toggleCell(move);
      gameClone.endTurn();
    }
    return gameClone;
  }

  /**
   * Expand the given node with a new node representing the given move.
   * Returns this new node.
   */
  MctsNode _expand(MctsNode node, int move) {
    MctsNode newNode = new MctsNode(parentNode: node, toggledCellID: move);
    node.childNodes.add(newNode);
    return newNode;
  }

  /**
   * Randomly playout the game from this node and return the winner.
   */
  double _playout(MctsNode node, Game gameAtParent) {
    Game g = gameAtParent.clone();
    //Bring the game to the node's state:
    g.toggleCell(node.toggledCellID);
    g.endTurn();
    return _getScore(g);
  }

  /**
   * Update all parent nodes with the playout result.
   */
  _backpropagate(MctsNode node, double score) {
    MctsNode currentNode = node;
    while (currentNode != rootNode) {
      currentNode.nVisits++;
      currentNode.score += score;
      currentNode = currentNode.parentNode;
    }
    rootNode.nVisits++;
  }

  /**
   * Return a score that rates the current player's chances to win
   * based on a simple calculation
   */
  double _getScore(Game g) {
    int livingCellsOfPlayer =
        g.board
            .getLivingCellsOfPlayer(game.currentPlayerId)
            .length;
    int livingCells = g.board
        .getLivingCells()
        .length;
    if (livingCells == 0) {
      return 1.0 /
          game
              .numberOfPlayers; // because draw should be considered if enemies take over
    }
    return livingCellsOfPlayer.toDouble() / livingCells.toDouble();
  }
}
