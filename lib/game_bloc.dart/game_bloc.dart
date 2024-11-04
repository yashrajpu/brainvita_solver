import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const int boardSize = 4;
  Timer? _turnTimer;
  int _timeRemaining = 10;

  GameBloc() : super(GameInitial()) {
    on<StartGame>(_onStartGame);
    on<PlaceMarble>(_onPlaceMarble);
    on<ResetGame>(_onResetGame);
    on<SwitchTurn>(_onSwitchTurn);
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    emit(GameInProgress(
      gameMatrix: List.generate(boardSize, (_) => List.filled(boardSize, '')),
      isPlayer1Turn: true,
      timeRemaining: _timeRemaining,
      gameHistory: [],
    ));
    _startTurnTimer(emit);
  }

  void _onPlaceMarble(PlaceMarble event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      var currentState = state as GameInProgress;
      var matrix = List<List<String>>.from(currentState.gameMatrix);
      if (matrix[event.x][event.y] == '') {
        matrix[event.x][event.y] = currentState.isPlayer1Turn ? 'P1' : 'P2';
        var history = List<String>.from(currentState.gameHistory)
          ..add('Turn: ${currentState.isPlayer1Turn ? 'Player 1' : 'Player 2'} - Placed at (${event.x}, ${event.y})');

        // Check for a winning condition after placing the marble
        if (_checkWinCondition(matrix)) {
          emit(GameOver(winner: currentState.isPlayer1Turn ? 'Player 1' : 'Player 2'));
          _turnTimer?.cancel();
        } else {
          // Move the marbles counterclockwise after each turn
          matrix = _moveMarblesCounterClockwise(matrix);
          emit(currentState.copyWith(gameMatrix: matrix, gameHistory: history));
          add(SwitchTurn());
        }
      }
    }
  }

  void _onSwitchTurn(SwitchTurn event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      var currentState = state as GameInProgress;
      var newIsPlayer1Turn = !currentState.isPlayer1Turn;
      _timeRemaining = 10; // Reset timer for the next player
      emit(currentState.copyWith(isPlayer1Turn: newIsPlayer1Turn, timeRemaining: _timeRemaining));
      _startTurnTimer(emit); // Start the turn timer for the new player
    }
  }

  void _onResetGame(ResetGame event, Emitter<GameState> emit) {
    _turnTimer?.cancel();
    add(StartGame());
  }

  void _startTurnTimer(Emitter<GameState> emit) {
    _turnTimer?.cancel(); // Cancel any existing timer
    _timeRemaining = 10; // Reset timer to 10 seconds
    _turnTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        if (state is GameInProgress) {
          var currentState = state as GameInProgress;
          emit(currentState.copyWith(timeRemaining: _timeRemaining));
        }
      } else {
        // Time is up, switch turn
        add(SwitchTurn());
      }
    });
  }

  bool _checkWinCondition(List<List<String>> matrix) {
    const directions = [
      [0, 1], [1, 0], [1, 1], [1, -1]
    ]; // Horizontal, Vertical, Diagonal Down, Diagonal Up
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        String player = matrix[i][j];
        if (player.isNotEmpty) {
          for (var dir in directions) {
            int count = 1;
            for (int step = 1; step < 4; step++) {
              int newX = i + step * dir[0];
              int newY = j + step * dir[1];
              if (newX >= 0 && newX < boardSize && newY >= 0 && newY < boardSize && matrix[newX][newY] == player) {
                count++;
              } else {
                break;
              }
            }
            if (count == 4) {
              return true; // Win condition met
            }
          }
        }
      }
    }
    return false; // No win condition met
  }

  List<List<String>> _moveMarblesCounterClockwise(List<List<String>> matrix) {
    // Create a new matrix for the counterclockwise movement
    List<List<String>> newMatrix = List.generate(boardSize, (_) => List.filled(boardSize, ''));

    // Move marbles counterclockwise
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        // Only move the marble if there's one present
        if (matrix[i][j] != '') {
          // Move the marble counterclockwise
          int newI = (i + 1) % boardSize; // Move down
          int newJ = (j == 0) ? boardSize - 1 : j - 1; // Move left
          newMatrix[newI][newJ] = matrix[i][j]; // Place marble in new position
        }
      }
    }
    return newMatrix;
  }

  @override
  Future<void> close() {
    _turnTimer?.cancel();
    return super.close();
  }
}
