import 'package:conway/conway.dart';
import 'package:test/test.dart';

import '../game/test_game.dart';

void main() {

  int _width = 3;
  int _height = 4;
  Board _board;
  Cell _cell;

  group('Test Board constructor', () {
    setUp(() async {
      _board = new Board(_width, _height);
    });
    test('Board contains VOID Cells', () {
      for(int i=0; i<_width*_height; i++) {
        expect(_board.getCell(i).state, CellState.VOID);
      }
    });
  });

  group('Test Setters and Getters for Cell', () {
    setUp(() async {
      _board = new Board(_width, _height);
      _cell = new Cell.Alive(0);
    });
    test('Test standard Getter and Setter', () {
      int index = 4;
      expect(_board.getCell(index).state, CellState.VOID);
      _board.setCell(index, _cell);
      expect(_board.getCell(index).state, CellState.ALIVE);
    });
    test('Test Getter and Setter by coordinates', () {
      int x = 1;
      int y = 2;
      int index = y * _width + x;
      expect(_board.getCellByCoordinates(x, y).state, CellState.VOID);
      _board.setCellByCoordinates(x, y, _cell);
      expect(_board.getCell(index).state, CellState.ALIVE);
    });
  });

  group('Test neighbour methods on two player board', () {
    setUp(() async {
      _board = new TestGame.TwoPlayers().board;
    });
    test('Test getNeighbour method', () {
      expect(_board.getNeighbour(0, -1, -1), null);
      expect(_board.getNeighbour(0,  0, -1), null);
      expect(_board.getNeighbour(0,  1, -1), null);
      expect(_board.getNeighbour(0, -1,  0), null);
      expect(_board.getNeighbour(0,  1,  0), _board.getCell(1));
      expect(_board.getNeighbour(0, -1,  1), null);
      expect(_board.getNeighbour(0,  0,  1), _board.getCell(5));
      expect(_board.getNeighbour(0,  1,  1), _board.getCell(6));
    });
    test('Test getNeighbours method', () {
      List<Cell> neighbours = _board.getNeighbours(0);
      expect(neighbours.length, 3);
      expect(neighbours[0], _board.getCell(1));
      expect(neighbours[1], _board.getCell(5));
      expect(neighbours[2], _board.getCell(6));
    });
  });

  group('Test neighbour methods on three player board', () {
    setUp(() async {
      _board = new TestGame.ThreePlayers().board;
    });
    test('Test getNeighbour method', () {
      expect(_board.getNeighbour(9, -1, -1), _board.getCell(4));
      expect(_board.getNeighbour(9,  0, -1), _board.getCell(5));
      expect(_board.getNeighbour(9,  1, -1), _board.getCell(6));
      expect(_board.getNeighbour(9, -1,  0), _board.getCell(8));
      expect(_board.getNeighbour(9,  1,  0), _board.getCell(10));
      expect(_board.getNeighbour(9, -1,  1), _board.getCell(12));
      expect(_board.getNeighbour(9,  0,  1), _board.getCell(13));
      expect(_board.getNeighbour(9,  1,  1), _board.getCell(14));
    });
    test('Test getNeighbours method', () {
      List<Cell> neighbours = _board.getNeighbours(9);
      expect(neighbours.length, 8);
      expect(neighbours[0], _board.getCell(4));
      expect(neighbours[1], _board.getCell(5));
      expect(neighbours[2], _board.getCell(6));
      expect(neighbours[3], _board.getCell(8));
      expect(neighbours[4], _board.getCell(10));
      expect(neighbours[5], _board.getCell(12));
      expect(neighbours[6], _board.getCell(13));
      expect(neighbours[7], _board.getCell(14));
    });
  });
}
