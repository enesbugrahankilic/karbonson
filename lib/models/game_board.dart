// lib/models/game_board.dart
import 'dart:math';

enum TileType {
  Start,       
  Quiz,        
  Bonus,       
  Penalty,     
  Finish,      
}

class BoardTile {
  final int index;
  final TileType type;
  final String label;

  BoardTile({required this.index, required this.type, required this.label});
}

class Player {
  final String nickname;
  int position;         
  int turnsToSkip;      
  int quizScore;        

  Player({
    required this.nickname, 
    this.position = 0, 
    this.turnsToSkip = 0,
    this.quizScore = 0,
  });
}

class GameBoard {
  static const int totalTiles = 25; 
  
  final List<BoardTile> tiles = [];

  GameBoard() {
    _initializeBoard();
  }

  void _initializeBoard() {
    final random = Random();
    
    for (int i = 0; i < totalTiles; i++) {
      TileType type;
      String label;

      if (i == 0) {
        type = TileType.Start;
        label = "Başla";
      } else if (i == totalTiles - 1) {
        type = TileType.Finish;
        label = "Bitiş";
      } else {
        int rand = random.nextInt(10); 
        
        if (rand < 4) { 
          type = TileType.Quiz;
          label = "Quiz 💡";
        } else if (rand < 7) { 
          type = TileType.Bonus;
          label = "+Bonus 💰";
        } else if (rand < 9) { 
          if (random.nextBool()) { 
             type = TileType.Penalty;
             label = "-Ceza 🛑";
          } else {
             type = TileType.Bonus; 
             label = "+Bonus 💰";
          }
        } else { 
          type = TileType.Quiz;
          label = "Quiz 💡";
        }
      }
      
      tiles.add(BoardTile(index: i, type: type, label: label));
    }
  }
}