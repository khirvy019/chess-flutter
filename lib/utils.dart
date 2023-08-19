import 'package:my_app/chess_piece.dart';

(int, int) indexToCoords(int index) {
  final y = index ~/ 8;
  final x = index % 8;
  // print("$x, $y : $index");
  return (x, y);
}

int coordsToIndex(int x, int y) {
  return y * 8 + x;
}

String indexToAlgebraicNotation(int index) {
  final coords = indexToCoords(index);
  return coordsToAlgebraicNotation(coords.$1, coords.$2);
}

String coordsToAlgebraicNotation(int x, int y) {
  const X = 'abcdefgh';

  final algebraicNotation = (X[x], (8-y).toString());
  return "${algebraicNotation.$1}${algebraicNotation.$2}";
}


bool isKingThreatened(List<ChessPiece> chessPieces, ChessSide side) {
  for(ChessPiece chessPiece in chessPieces) {
    if (chessPiece.side != side || chessPiece.runtimeType != ChessPieceKing) continue;
    return chessPiece.isThreatened(chessPieces);
  }
  return false;
}

(List<ChessPiece> updatedPieces, ChessPiece eatenPiece) movePieceCheck(List<ChessPiece> chessPieces, int sourceIndex, int destinationIndex, { bool clone=false }) {
  ChessPiece movedPiece = chessPieces[sourceIndex];
  ChessPiece movedToTile = chessPieces[destinationIndex];
  if (movedPiece.side == movedToTile.side) return (chessPieces, ChessPiece(null));

  if (clone) {
    final clonedPieces = chessPieces.map((piece) => piece.clone()).toList();
    // print("Cloned pieces: $clonedPieces");
    return movePieceCheck(
      clonedPieces,
      sourceIndex, destinationIndex,
      clone: false,
    );
  }

  chessPieces[destinationIndex] = movedPiece;
  chessPieces[sourceIndex] = ChessPiece(null);
  return (chessPieces, movedToTile);
}
