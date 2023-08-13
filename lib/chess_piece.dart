import "utils.dart";

enum ChessSide { black, white }
String formatChessSide(ChessSide? side) {
  if (side == ChessSide.black){ return 'Black'; }
  if (side == ChessSide.white){ return 'White'; }

  return '';
}

class ChessPiece {
  final ChessSide? side;
  const ChessPiece(this.side);

  String icon() {
    return '';
  }

  /// Returns list of directions that the piece can move to.
  /// Each element represents a direction (e.g east, west north, south)
  /// The numbers in each element are the indices that covers the direction
  /// For instance rook can move in 4 directions right or down only, if it is in index 0(top-left),
  /// this returns
  /// [
  ///   [],                     // -> up
  ///   [8,16,24,32,40,48,56],  // -> down
  ///   [1, 2, 3, 4, 5, 6, 7],  // -> left
  ///   [],                     // -> right
  /// ]
  List<List<int>> getDirectionalMoves(int index) {
    return [];
  }

  List<int> getDirectionalMoveIndices(int index) {
    List<List<int>> locations = getDirectionalMoves(index);
    return locations.expand((direction) => direction).toList();
  }

  List<int> getMovableIndices(List<ChessPiece> chessPieces, int index) {
    final directionalMoves = getDirectionalMoves(index);
    final filteredLocations = directionalMoves.map((direction) {
      List<int> indices = [];
      for(var i = 0; i < direction.length; i ++) {
        int pieceIndex = direction[i];
        ChessPiece piece = chessPieces[pieceIndex];
        if (piece.icon().isEmpty) {
          indices.add(pieceIndex);
          continue;
        } else {
          if (piece.side != side) indices.add(pieceIndex);
          break;
        }
      }

      return indices;
    }).toList();

    return filteredLocations.expand((direction) => direction).toList();
  }

  static ChessPiece parse(String icon) {
    switch(icon) {
      case "♜":
        return ChessPieceRook(ChessSide.black);
      case "♞":
        return ChessPieceHorse(ChessSide.black);
      case "♝":
        return ChessPieceBishop(ChessSide.black);
      case "♛":
        return ChessPieceQueen(ChessSide.black);
      case "♚":
        return ChessPieceKing(ChessSide.black);
      case "♟":
        return ChessPiecePawn(ChessSide.black);

      case "♖":
        return ChessPieceRook(ChessSide.white);
      case "♘":
        return ChessPieceHorse(ChessSide.white);
      case "♗":
        return ChessPieceBishop(ChessSide.white);
      case "♕":
        return ChessPieceQueen(ChessSide.white);
      case "♔":
        return ChessPieceKing(ChessSide.white);
      case "♙":
        return ChessPiecePawn(ChessSide.white);
      default:
        return ChessPiece(null);
    }
  }
}


class ChessPieceKing extends ChessPiece {
  ChessPieceKing(super.side);
  @override
  String icon() {
    return side == ChessSide.black ? "♚" : "♔";
  }

  @override
  List<List<int>> getDirectionalMoves(int index) {
    List<List<int>> locations = generateDirectionalMoves(index, List.filled(8, 1));
    return locations;
  }
}

class ChessPieceQueen extends ChessPiece {
  ChessPieceQueen(super.side);
  @override
  String icon() {
    return side == ChessSide.black ? "♛" : "♕";
  }

  @override
  List<List<int>> getDirectionalMoves(int index) {
    List<List<int>> locations = generateDirectionalMoves(index, List.filled(8, 7));
    return locations;
  }
}

class ChessPieceBishop extends ChessPiece {
  ChessPieceBishop(super.side);
  @override
  String icon() {
    return side == ChessSide.black ? "♝" : "♗";
  }

  @override
  List<List<int>> getDirectionalMoves(int index) {
    List<List<int>> locations = generateDirectionalMoves(index, [
      0, 7,
      0, 7,
      0, 7,
      0, 7,
    ]);
    return locations;
  }
}

class ChessPieceHorse extends ChessPiece {
  ChessPieceHorse(super.side);
  @override
  String icon() {
    return side == ChessSide.black ? "♞" : "♘";
  }

  @override
  List<List<int>> getDirectionalMoves(int index) {
    final pos = indexToCoords(index);
    List<List<(int, int)>> locations = [
      [(pos.$1+1, pos.$2-2)],
      [(pos.$1-1, pos.$2-2)],

      [(pos.$1+2, pos.$2+1)],
      [(pos.$1+2, pos.$2-1)],

      [(pos.$1+1, pos.$2+2)],
      [(pos.$1-1, pos.$2+2)],

      [(pos.$1-2, pos.$2+1)],
      [(pos.$1-2, pos.$2-1)],
    ];
    locations = filterOutOfBounds(locations);

    return locations.map((directions) {
      return directions.map((coords) => coordsToIndex(coords.$1, coords.$2)).toList();
    }).toList();
  }
}

class ChessPieceRook extends ChessPiece {
  ChessPieceRook(super.side);

  @override
  String icon() {
    return side == ChessSide.black ? "♜" : "♖";
  }

  @override
  List<List<int>> getDirectionalMoves(int index) {
    List<List<int>> locations = generateDirectionalMoves(index, [
      7, 0,
      7, 0,
      7, 0,
      7, 0,
    ]);
    locations = locations.map((List<int> direction) {
      return direction.where((int i) => 0 <= i && i <= 63).toList();
    }).toList();

    return locations;
  }
}

class ChessPiecePawn extends ChessPiece {
  ChessPiecePawn(super.side);

  @override
  List<List<int>> getDirectionalMoves(int index) {
    List<int> directions = List.filled(8, 0);

    final coords = indexToCoords(index);
    bool canMove2TilesForward = false;
    if (coords.$2 == 1 && side == ChessSide.white) { canMove2TilesForward = true; }
    else if(coords.$2 == 6 && side == ChessSide.black) { canMove2TilesForward = true; }

    directions[side == ChessSide.white ? 4 : 0] = canMove2TilesForward ? 2 : 1;
    List<List<int>> locations = generateDirectionalMoves(index, directions);
    return locations;
  }

  @override
  List<int> getMovableIndices(List<ChessPiece> chessPieces, int index) {
    final movableIndices = super.getMovableIndices(chessPieces, index);
    // if the parent function does its job well,
    // the last element should be the farthest forward move
    int lastForwardMoveIndex = movableIndices.last;
    final forwardTile = chessPieces[lastForwardMoveIndex];
    if (forwardTile.icon().isNotEmpty) movableIndices.remove(lastForwardMoveIndex);

    // check for diagonal forward moves that it can eat
    List<int> checkEnemyExists = [];
    if (side == ChessSide.black) checkEnemyExists = [index-9, index-7]; // Northwest & Northwest tile
    if (side == ChessSide.white) checkEnemyExists = [index+9, index+7]; // Southeast & Southwest tile
    for (var indexToCheck in checkEnemyExists) {
      if (indexToCheck < 0 || indexToCheck >= 64) continue;

      final piece = chessPieces[indexToCheck];
      if (piece.side != null && side != piece.side) movableIndices.add(indexToCheck);
    }
    return movableIndices;
  }

  @override
  String icon() {
    return side == ChessSide.black ? "♟" : "♙";
  }
}

/// Tool for generating indices for directional moves of a piece given a position
/// in the board [0-63]
/// Each index represent the following directions:
///   North, NE, East, SE, South, SW, West, NW
/// while each number represent the number of steps possible
/// 
/// Note that this does not account for 
List<List<int>> generateDirectionalMoves(int position, List<int> directions) {
  final pos = indexToCoords(position);
  // Generate coordinates for each direction
  List<List<(int, int)>> locations = [
    List<(int, int)>.generate(directions[0], (int i) => (pos.$1, pos.$2-i-1)), // North
    List<(int, int)>.generate(directions[1], (int i) => (pos.$1+i+1, pos.$2-i-1)), // Northeast
    List<(int, int)>.generate(directions[2], (int i) => (pos.$1+i+1, pos.$2)), // East
    List<(int, int)>.generate(directions[3], (int i) => (pos.$1+i+1, pos.$2+i+1)), // Southeast
    List<(int, int)>.generate(directions[4], (int i) => (pos.$1, pos.$2+i+1)), // South
    List<(int, int)>.generate(directions[5], (int i) => (pos.$1-i-1, pos.$2+i+1)), // Southwest
    List<(int, int)>.generate(directions[6], (int i) => (pos.$1-i-1, pos.$2)), // West
    List<(int, int)>.generate(directions[7], (int i) => (pos.$1-i-1, pos.$2-i-1)), // Northwest
  ];

  // Filter out coordinates outside the 8x8 board
  locations = filterOutOfBounds(locations);

  // Convert each coordinate into index
  List<List<int>> locationIndices = locations.map((direction) {
    return direction.map((coords) => coordsToIndex(coords.$1, coords.$2)).toList();
  }).toList();
  return locationIndices;
}

List<List<(int, int)>> filterOutOfBounds(List<List<(int, int)>> locations) {
  return locations.map((directions) {
    return directions.where((coords) {
      return 0 <= coords.$1 && coords.$1 <= 7 &&
            0 <= coords.$2 && coords.$2 <= 7;
    }).toList();
  }).toList();
}
