# Conway Lib

## Overview
Library that simulates Conway's Game of Life with multiple players.
The last player with living cells wins the game.

## Setup

### Prerequisites
Install the [Dart SDK](https://dart.dev/get-dart).

### Run
`dart example/conway_example.dart`

### Run Tests
`pub run test test/`

## Releases

### 1.1.10
- Added sudden death mechanics: A `Game` can be constructed with an optional `roundsBeforeSuddenDeath` parameter.
After this number of rounds, an increasing amount of `Cells` will be removed from the `Board` before each round.
- Added a read-only member variable `round` to `Game`, which counts how many rounds have been played.
