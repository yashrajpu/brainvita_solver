import 'package:brainvita_solver/game_bloc.dart/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4x4 Marble Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => GameBloc()..add(StartGame()),
        child: GameBoard(),
      ),
    );
  }
}
class GameBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is GameInitial) {
          return Center(child: CircularProgressIndicator());
        } else if (state is GameInProgress) {
          return _buildGameUI(context, state);
        } else if (state is GameOver) {
          return _buildGameOverUI(context, state);
        }
        return Container(); // Fallback
      },
    );
  }

  Widget _buildGameUI(BuildContext context, GameInProgress state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('4x4 Marble Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Show game history dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Game History"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: state.gameHistory.map((move) => Text(move)).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < GameBloc.boardSize; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < GameBloc.boardSize; j++)
                    GestureDetector(
                      onTap: () => context.read<GameBloc>().add(PlaceMarble(i, j)),
                      child: Container(
                        margin: EdgeInsets.all(4),
                        width: 50,
                        height: 50,
                        color: state.gameMatrix[i][j] == '' ? Colors.grey : (state.gameMatrix[i][j] == 'P1' ? Colors.blue : Colors.red),
                        child: Center(child: Text(state.gameMatrix[i][j], style: TextStyle(color: Colors.white, fontSize: 24))),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            Text('Turn: ${state.isPlayer1Turn ? 'Player 1' : 'Player 2'}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Time Remaining: ${state.timeRemaining}s', style: TextStyle(fontSize: 20)), // Displaying the timer
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<GameBloc>().add(ResetGame()),
              child: Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverUI(BuildContext context, GameOver state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${state.winner} Wins!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<GameBloc>().add(ResetGame()),
            child: Text('Reset Game'),
          ),
        ],
      ),
    );
  }
}
