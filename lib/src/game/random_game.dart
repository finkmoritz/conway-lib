import 'dart:math';

import '../cell/cell.dart';
import 'game.dart';

class RandomGame extends Game {
  RandomGame(
      {numberOfPlayers = 2,
      width = 5,
      height = 5,
      roundsBeforeSuddenDeath,
      double fractionLivingCells = 0.5,
      double fractionDeadCells = 0.3})
      : super(
            numberOfPlayers: numberOfPlayers,
            width: width,
            height: height,
            roundsBeforeSuddenDeath: roundsBeforeSuddenDeath) {
    int totalCells = width * height;
    int cellsPerPlayer =
        (fractionLivingCells * totalCells / numberOfPlayers).floor();
    int livingCells = cellsPerPlayer * numberOfPlayers as int;
    int deadCells = (fractionDeadCells * totalCells).floor();
    int voidCells = totalCells - livingCells - deadCells;
    List<Cell> cells = [
      ...new List.generate(
          livingCells, (i) => new Cell.Alive(i % numberOfPlayers as int)),
      ...new List.generate(deadCells, (i) => new Cell.Dead()),
      ...new List.generate(voidCells, (i) => new Cell.Void())
    ];
    Random rng = new Random(DateTime.now().millisecondsSinceEpoch);
    cells.shuffle(rng);
    for(int i=0; i<cells.length; i++) {
      this.board.setCell(i, cells[i]);
    }
  }
}
