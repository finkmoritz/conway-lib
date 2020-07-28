import 'package:conway/conway.dart';

class TestGame extends Game {

  /**
   * # 0 0 # #
   * 0 1 1   1
   *   # 0 1 #
   * 1 # # 0 1
   * 1 #   0 0
   */
  TestGame.TwoPlayers() {
    [1, 2, 5, 12, 18, 23, 24].forEach((index) {
      this.board.setCell(index, new Cell.Alive(0));
    });
    [6, 7, 9, 13, 15, 19, 20].forEach((index) {
      this.board.setCell(index, new Cell.Alive(1));
    });
    [0, 3, 4, 11, 14, 16, 17, 21].forEach((index) {
      this.board.setCell(index, new Cell.Dead());
    });
  }

  /**
   * 0 # 0 1 #
   * 0 # #   #
   *   # # # #
   * # 1 # # #
   * # #   0 0
   */
  TestGame.TwoPlayersAfterToggleCell0() {
    [0, 2, 5, 23, 24].forEach((index) {
      this.board.setCell(index, new Cell.Alive(0));
    });
    [3, 16].forEach((index) {
      this.board.setCell(index, new Cell.Alive(1));
    });
    [1, 4, 6, 7, 9, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21].forEach((index) {
      this.board.setCell(index, new Cell.Dead());
    });
  }
}
