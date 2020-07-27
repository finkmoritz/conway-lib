import 'package:conway/conway.dart';
import 'package:test/test.dart';

void main() {

  Cell _cell;

  group('Test Cells in state VOID', () {
    setUp(() async {
      _cell = new Cell.Void();
    });
    test('VOID Cell cannot be revived', () {
      expect(() {_cell.revive(0);}, throwsException);
    });
    test('VOID Cell cannot be killed', () {
      expect(() {_cell.kill();}, throwsException);
    });
  });

  group('Test Cells in state ALIVE', () {
    setUp(() async {
      _cell = new Cell.Alive(0);
    });
    test('ALIVE Cell cannot be revived', () {
      expect(() {_cell.revive(0);}, throwsException);
    });
    test('ALIVE Cell can be killed', () {
      _cell.kill();
      expect(_cell.state, CellState.DEAD);
      expect(_cell.playerID, null);
    });
  });

  group('Test Cells in state DEAD', () {
    setUp(() async {
      _cell = new Cell.Dead();
    });
    test('DEAD Cell can be revived', () {
      _cell.revive(0);
      expect(_cell.state, CellState.ALIVE);
      expect(_cell.playerID, 0);
    });
    test('DEAD Cell cannot be killed', () {
      expect(() => _cell.kill(), throwsException);
    });
  });
}
