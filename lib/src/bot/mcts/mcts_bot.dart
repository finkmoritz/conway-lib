import 'dart:math';

import '../../bot/random_bot.dart';
import '../../game/game.dart';
import '../bot.dart';
import 'mcts_node.dart';

/**
 * Bot that uses a Monte Carlo Tree Search (MCTS) algorithm to find
 * a good move. The higher the number of iterations and the playout
 * depth the better moves it will find but also consume more time.
 */
class MctsBot extends Bot {

  int maxPlayoutDepth;

  Random _rng;
  MctsNode rootNode;

  MctsBot(Game game, {this.maxPlayoutDepth = 25})
      : super(game) {
    _rng = new Random(DateTime.now().millisecondsSinceEpoch);
    _reset();
  }

  /**
   * Play a move by application of the MCTS algorithm. The node with
   * the highest number of visits is chosen to be the best move.
   */
  @override
  int play({int numberOfIterations = 1000}) {
    iterate(numberOfIterations: numberOfIterations);
    List<MctsNode> rankedNodes = getRankedNodes();
    int move = rankedNodes[0].toggledCellID;
    game.toggleCell(move);
    return move;
  }

  /**
   * Apply the given number of iterations to develop the search tree.
   * Per default the search tree will be reset at each invocation of
   * this method. When reset=false, the tree will not be reset (only
   * use this option if the game state has not been changed in between
   * iterations!)
   */
  void iterate({int numberOfIterations = 100, bool reset = true}) {
    if(reset) {
      _reset();
    }
    int i = 0;
    while(i < numberOfIterations) {
      List<MctsNode> path = _selectNodeForPlayout(rootNode);
      MctsNode selectedNode = path.last;
      Game gameAtSelectedNode = _computeGameAfterPath(path);
      List<int> reasonableMoves = gameAtSelectedNode.getReasonableMoves();
      if (reasonableMoves.isEmpty) {
        i++;
        _backpropagate(selectedNode, gameAtSelectedNode.winner);
      } else {
        reasonableMoves.forEach((move) {
          i++;
          MctsNode newNode = _expand(selectedNode, gameAtSelectedNode, move);
          int winner = _playout(newNode, gameAtSelectedNode);
          _backpropagate(newNode, winner);
        });
      }
    }
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
        node.childNodes.isEmpty &&
        node.nWins == node.nVisits;
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
    while(currentNode.childNodes.isNotEmpty) {
      Function(MctsNode) explorationScore = (MctsNode n) => n.getExplorationScore();
      currentNode = _getNodeWithHighestEval(currentNode.childNodes, explorationScore);
      path.add(currentNode);
    }
    return path;
  }

  /**
   * Returns the node with the highest return value of the eval function.
   * If multiple nodes have the same value, one of those will
   * be chosen at random.
   */
  MctsNode _getNodeWithHighestEval(List<MctsNode> nodes, Function(MctsNode) eval) {
    double maxScore = 0;
    List<MctsNode> bestNodes = [];
    nodes.forEach((node) {
      double evalScore = eval(node);
      if(evalScore > maxScore) {
        maxScore = evalScore;
        bestNodes = [node];
      } else if(evalScore == maxScore) {
        bestNodes.add(node);
      }
    });
    MctsNode bestNode = bestNodes[0];
    if(bestNodes.length > 1) {
      int randomIndex = _rng.nextInt(bestNodes.length);
      bestNode = bestNodes[randomIndex];
    }
    return bestNode;
  }

  /**
   * Compute the Game state after the given path of nodes.
   */
  Game _computeGameAfterPath(List<MctsNode> path) {
    Game gameClone = game.clone();
    for(int i=1; i<path.length; i++) {
      int move = path[i].toggledCellID;
      gameClone.toggleCell(move);
    }
    return gameClone;
  }

  /**
   * Expand the given node with a new node representing the given move.
   * Returns this new node.
   */
  MctsNode _expand(MctsNode node, Game game, int move) {
    MctsNode newNode = new MctsNode(parentNode: node, toggledCellID: move);
    node.childNodes.add(newNode);
    return newNode;
  }

  /**
   * Randomly playout the game from this node and return the winner.
   */
  int _playout(MctsNode node, Game gameAtParent) {
    Game g = gameAtParent.clone();
    //Bring the game to the node's state:
    g.toggleCell(node.toggledCellID);
    //Playout randomly afterwards:
    RandomBot randomBot = new RandomBot(g);
    int i = 0;
    while(i++ < maxPlayoutDepth && !g.gameOver) {
      randomBot.play();
    }
    return g.winner;
  }

  /**
   * Update all parent nodes with the playout result.
   */
  _backpropagate(MctsNode node, int winner) {
    bool currentPlayerWins = winner == game.currentPlayer;
    MctsNode currentNode = node;
    while (currentNode != rootNode) {
      currentNode.nVisits++;
      if (winner == null) {
        currentNode.nWins += 0.5;
      } else if (currentPlayerWins) {
        currentNode.nWins += 1.0;
      }
      currentNode = currentNode.parentNode;
    }
    rootNode.nVisits++;
  }
}
