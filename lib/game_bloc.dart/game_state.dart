part of 'game_bloc.dart';

abstract class GameState {
  const GameState();
}

class GameInitial extends GameState {}

class GameInProgress extends GameState {
  final List<List<String>> gameMatrix;
  final bool isPlayer1Turn;
  final int timeRemaining;
  final List<String> gameHistory;

  GameInProgress({
    required this.gameMatrix,
    required this.isPlayer1Turn,
    required this.timeRemaining,
    required this.gameHistory,
  });

  GameInProgress copyWith({
    List<List<String>>? gameMatrix,
    bool? isPlayer1Turn,
    int? timeRemaining,
    List<String>? gameHistory,
  }) {
    return GameInProgress(
      gameMatrix: gameMatrix ?? this.gameMatrix,
      isPlayer1Turn: isPlayer1Turn ?? this.isPlayer1Turn,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      gameHistory: gameHistory ?? this.gameHistory,
    );
  }
}

class GameOver extends GameState {
  final String winner;

  GameOver({required this.winner});
}
