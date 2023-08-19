import 'package:my_app/chess_piece.dart';
import 'utils.dart';

class ChessGameHandler {
  ChessSide? currentTurn;
  List<ChessPiece> chessPieces = [
    '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖',
    '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
    '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
  ].map((e) => ChessPiece.parse(e)).toList();

  // turn, source-index, destination-index, chess-piece-eaten, was-initial-move(for pawns)
  List<(ChessSide?, int, int, String)> moveLogs = []; 
  int logStateIndex = -1;

  void reset() {
    chessPieces = [
      '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖',
      '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
      ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
      ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
      ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
      ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
      '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
      '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
    ].map((e) => ChessPiece.parse(e)).toList();
    currentTurn = null;
    moveLogs = [];
    logStateIndex = -1;
  }

  void movePiece(int index, int destinationIndex) {
    ChessPiece pieceToMove = chessPieces[index];
    if (pieceToMove.side != currentTurn) return;

    final result = movePieceCheck(chessPieces, index, destinationIndex);

    logStateIndex += 1;
    final moveLog = (currentTurn, index, destinationIndex, result.$2.icon());
    moveLogs = moveLogs.sublist(0, logStateIndex);
    moveLogs.add(moveLog);
    print("$moveLog");
  }

  void undoLastMove() {
    if (moveLogs.isEmpty || logStateIndex < 0) return;
    final moveLog = moveLogs[logStateIndex];

    currentTurn = moveLog.$1;

    final movedPiece = chessPieces[moveLog.$3];
    chessPieces[moveLog.$3] = ChessPiece.parse(moveLog.$4);
    chessPieces[moveLog.$2] = movedPiece;

    logStateIndex--;
  }

  bool canMoveTo(int index, int destinationIndex) {
    ChessPiece fromPiece = chessPieces[index];
    ChessPiece destPiece = chessPieces[destinationIndex];
    if (fromPiece.icon().isEmpty) return false;
    if (canMoveAsPiece(index, destinationIndex)) return false;
    return destPiece.icon().isEmpty || fromPiece.side != destPiece.side;
  }

  ChessSide toggleTurn() {
    ChessSide nextTurn = currentTurn == ChessSide.white ? ChessSide.black : ChessSide.white;
    currentTurn = nextTurn;
    return nextTurn;
  }

  bool canMoveAsPiece(int index, int destinationIndex) {
    ChessPiece piece = chessPieces[index];
    if (piece.icon().isEmpty) return false;

    return piece.getMovableIndices(chessPieces, index).contains(destinationIndex);
  }
}
