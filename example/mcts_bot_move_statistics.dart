import 'package:conway/conway.dart';

void main() {
  int createCell = 0;
  int destroyFriendlyCell = 0;
  int destroyHostileCell = 0;
  int iterations = 1000;

  for(int i=0; i<iterations; i++) {
    print('Iteration ${i+1} of $iterations:');
    Game game = new RandomGame(numberOfPlayers: 2, width: 5,
        height: 5, fractionLivingCells: 0.65, fractionDeadCells: 0.25);
    MctsBot mctsBot = new MctsBot(game, maxPlayoutDepth: 50);
    mctsBot.iterate(numberOfIterations: 25000);
    int move = mctsBot.getRankedNodes()[0].toggledCellID;
    Cell cell = game.board.getCell(move);
    switch(cell.state) {
      case CellState.ALIVE:
        if(cell.playerID == game.currentPlayer) {
          destroyFriendlyCell++;
        } else {
          destroyHostileCell++;
        }
        break;
      case CellState.DEAD:
        createCell++;
        break;
    }
    print('Create / Destroy friendly / Destroy hostile: '
        '$createCell / $destroyFriendlyCell / $destroyHostileCell');
  }
}
