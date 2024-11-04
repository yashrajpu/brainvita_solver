part of 'game_bloc.dart';

abstract class GameEvent {}

class StartGame extends GameEvent {}

class PlaceMarble extends GameEvent {
  final int x;
  final int y;

  PlaceMarble(this.x, this.y);
}

class ResetGame extends GameEvent {}

class SwitchTurn extends GameEvent {}
