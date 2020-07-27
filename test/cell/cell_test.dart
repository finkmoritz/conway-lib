import 'package:conway/conway.dart';
import 'package:test/test.dart';

void main() {

  Cell cell;

  group('Test Cells in state VOID', () {
    setUp(() async {
      cell = new Cell.Void();
    });
    test('VOID Cell cannot be revived', () {
      expect(() {cell.revive(0);}, throwsException);
    });
    test('VOID Cell cannot be killed', () {
      expect(() {cell.kill();}, throwsException);
    });
  });

  group('Test Cells in state ALIVE', () {
    setUp(() async {
      cell = new Cell.Alive(0);
    });
    test('ALIVE Cell cannot be revived', () {
      expect(() {cell.revive(0);}, throwsException);
    });
    test('ALIVE Cell can be killed', () {
      cell.kill();
      expect(cell.state, CellState.DEAD);
      expect(cell.playerID, null);
    });
  });

  group('Test Cells in state DEAD', () {
    setUp(() async {
      cell = new Cell.Dead();
    });
    test('DEAD Cell can be revived', () {
      cell.revive(0);
      expect(cell.state, CellState.ALIVE);
      expect(cell.playerID, 0);
    });
    test('DEAD Cell cannot be killed', () {
      expect(() => cell.kill(), throwsException);
    });
  });
}
