import 'dart:math';

import 'package:conway/src/bot/mcts/playout_result.dart';
import 'package:conway/src/bot/simple_bot.dart';

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
  int play({int maxNumberOfIterations = 10000, Duration maxDuration}) {
    iterate(
        maxNumberOfIterations: maxNumberOfIterations, maxDuration: maxDuration);
    int move = getRankedMoves()[0];
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
        i++;
        _backpropagate(
            selectedNode,
            new PlayoutResult(
              gameOver: gameAtSelectedNode.gameOver,
              winner: gameAtSelectedNode.winner,
            ));
      } else {
        reasonableMoves.forEach((move) {
          i++;
          MctsNode newNode = _expand(selectedNode, gameAtSelectedNode, move);
          PlayoutResult playoutResult = _playout(newNode, gameAtSelectedNode);
          _backpropagate(newNode, playoutResult);
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
        node.childNodes.isEmpty &&
        node.score == node.nVisits;
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
  PlayoutResult _playout(MctsNode node, Game gameAtParent) {
    Game g = gameAtParent.clone();
    //Bring the game to the node's state:
    g.toggleCell(node.toggledCellID);
    //Playout fast and simple afterwards:
    SimpleBot simpleBot = new SimpleBot(g);
    int i = 0;
    while (i++ < maxPlayoutDepth && !g.gameOver) {
      bool stillAlive = g.board
          .getLivingCellsOfPlayer(game.currentPlayer)
          .length > 0;
      if (!stillAlive) {
        break;
      }
      simpleBot.play();
    }
    return new PlayoutResult(
      gameOver: g.gameOver,
      winner: g.winner,
      survivedTurns: i - 1,
    );
  }

  /**
   * Update all parent nodes with the playout result.
   */
  _backpropagate(MctsNode node, PlayoutResult playoutResult) {
    MctsNode currentNode = node;
    while (currentNode != rootNode) {
      currentNode.nVisits++;
      if (playoutResult.gameOver) {
        if (playoutResult.winner == null) {
          currentNode.score += 0.5;
        } else if (playoutResult.winner == game.currentPlayer) {
          currentNode.score += 1.0;
        }
      } else {
        currentNode.score += 0.25 * playoutResult.survivedTurns.toDouble() /
            maxPlayoutDepth.toDouble();
      }
      currentNode = currentNode.parentNode;
    }
    rootNode.nVisits++;
  }
}
