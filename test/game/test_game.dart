import 'package:conway/conway.dart';

class TestGame extends Game {

  /**
   *   0 0 # #
   * 0 # #   #
   *   # 0 # #
   * # # # 0 #
   * # #   0 0
   */
  TestGame.SinglePlayer() : super(numberOfPlayers: 1) {
    [1, 2, 5, 12, 18, 23, 24].forEach((index) {
      this.board.setCell(index, new Cell.Alive(0));
    });
    [3, 4, 6, 7, 9, 11, 13, 14, 15, 16, 17, 19, 20, 21].forEach((index) {
      this.board.setCell(index, new Cell.Dead());
    });
  }

  /**
   *   0 # # #
   * # # 0   #
   *   # # # #
   * # # # 0 #
   * # #   # #
   */
  TestGame.SinglePlayerAfterToggleCell18() : super(numberOfPlayers: 1) {
    [1, 7, 18].forEach((index) {
      this.board.setCell(index, new Cell.Alive(0));
    });
    [2, 5, 3, 4, 6, 9, 11, 12, 13, 14, 15, 16, 17, 19, 20, 21, 23, 24].forEach((index) {
      this.board.setCell(index, new Cell.Dead());
    });
  }

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

  /**
   * 1 2 # 0
   * # 2 # #
   * 0 0 1 0
   *   # 2 #
   *     # #
   * 1 1 2
   */
  TestGame.ThreePlayers()
      : super(numberOfPlayers: 3, width: 4, height: 6) {
    [3, 8, 9, 11].forEach((index) {
      this.board.setCell(index, new Cell.Alive(0));
    });
    [0, 10, 20, 21].forEach((index) {
      this.board.setCell(index, new Cell.Alive(1));
    });
    [1, 5, 14, 22].forEach((index) {
      this.board.setCell(index, new Cell.Alive(2));
    });
    [2, 4, 6, 7, 13, 15, 18, 19].forEach((index) {
      this.board.setCell(index, new Cell.Dead());
    });
  }

  /**
   * 1 2 2 #
   * # # # 0
   * 0 # # 0
   *   # 2 0
   *     2 #
   * # 1 #
   */
  TestGame.ThreePlayersAfterToggleCell4()
      : super(numberOfPlayers: 3, width: 4, height: 6) {
    [7, 8, 11, 15].forEach((index) {
      this.board.setCell(index, new Cell.Alive(0));
    });
    [0, 21].forEach((index) {
      this.board.setCell(index, new Cell.Alive(1));
    });
    [1, 2, 14, 18].forEach((index) {
      this.board.setCell(index, new Cell.Alive(2));
    });
    [3, 4, 5, 6, 9, 10, 13, 19, 20, 22].forEach((index) {
      this.board.setCell(index, new Cell.Dead());
    });
  }
}
