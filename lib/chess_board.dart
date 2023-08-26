import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/chess_gamehandler.dart';
import 'package:my_app/chess_piece.dart';
import 'utils.dart';


class Chessboard extends StatefulWidget {
  @override
  ChessboardState createState() => ChessboardState();
}

class ChessboardState extends State<Chessboard> {
  ChessGameHandler gameHandler = ChessGameHandler();
  int selectedPieceIndex = -1;
  List<int> movableTiles = [];

  setSelectedPieceIndex(int index) {
    final selectedPiece = index < 0 ? null : gameHandler.chessPieces.elementAtOrNull(index);
    movableTiles = selectedPiece == null ? [] : selectedPiece.getMovableIndices(gameHandler.chessPieces, index);
    print("Movable indices: $movableTiles");
    selectedPieceIndex = index;
  }

  Image? resolveImage(ChessPiece piece) {
    String imageFileName = '';
    if (piece.side == null) return null;

    switch (piece.runtimeType) {
      case ChessPieceKing:
        imageFileName = piece.side == ChessSide.black ? 'black_king' : 'white_king';
        break;
      case ChessPieceQueen:
        imageFileName = piece.side == ChessSide.black ? 'black_queen' : 'white_queen';
        break;
      case ChessPieceBishop:
        imageFileName = piece.side == ChessSide.black ? 'black_bishop' : 'white_bishop';
        break;
      case ChessPieceHorse:
        imageFileName = piece.side == ChessSide.black ? 'black_horse' : 'white_horse';
        break;
      case ChessPieceRook:
        imageFileName = piece.side == ChessSide.black ? 'black_rook' : 'white_rook';
        break;
      case ChessPiecePawn:
        imageFileName = piece.side == ChessSide.black ? 'black_pawn' : 'white_pawn';
        break;
    }

    if (imageFileName.isNotEmpty) {
      return Image.asset('assets/images/pieces/$imageFileName.png');
    }
    return null;
  }

  startGame() {
    if (gameHandler.currentTurn != null) {
      print("Game is already started");
      return;
    }

    print("Starting");
    gameHandler.toggleTurn();
    print("Current turn: ${gameHandler.currentTurn}");

  }

  startGameDialog(BuildContext context) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text("Start game"),
      onPressed: () => setState(() {
        gameHandler.reset();
        selectedPieceIndex = -1;
        startGame();
        Navigator.of(context, rootNavigator: true).pop('dialog');
      }),
    );

    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Start game"),
      // content: Text("Restart match are you sure?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  restartGameConfirm(BuildContext context) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text("Restart game"),
      onPressed: () => setState(() {
        gameHandler.reset();
        selectedPieceIndex = -1;
        Navigator.of(context, rootNavigator: true).pop('dialog');
      }),
    );

    Widget cancelButton = ElevatedButton(
      child: Text("Continue game"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Restart game"),
      content: Text("Restart match are you sure?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    GridView chessGrid = GridView.builder(
      itemCount: 64,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (BuildContext context, int index) {
        final (row, col) = indexToCoords(index);
        final isWhite = (row + col) % 2 == 0;
        final color = isWhite ? Colors.white : Colors.brown;
        final piece = gameHandler.chessPieces[index];
        final isSelected = selectedPieceIndex == index;

        Border? border;
        if (isSelected) border = Border.all(color: Colors.brown.shade900, width: 4);
        if (movableTiles.contains(index)) border = Border.all(color: Colors.brown.shade900, width: 4);
        if (piece.runtimeType == ChessPieceKing && piece.isThreatened(gameHandler.chessPieces)) {
          border = Border.all(color: Colors.red, width: 4);
        }

        final cellContent = Column(mainAxisAlignment: MainAxisAlignment.center, children: []);
        final pieceImage = resolveImage(piece);
        if (pieceImage != null) cellContent.children.add(pieceImage);

        onCellClick() => setState(() {
          final clickedPiece = gameHandler.chessPieces[index];
          print("Clicked: ${clickedPiece.icon()}");
          if (gameHandler.currentTurn == null) {
            startGameDialog(context);
            return;
          }

          if (selectedPieceIndex >= 0) {
            if (gameHandler.canMoveAsPiece(selectedPieceIndex, index)) {
              gameHandler.movePiece(selectedPieceIndex, index);
              gameHandler.toggleTurn();
              print("Current turn: ${gameHandler.currentTurn}");
            }
            setSelectedPieceIndex(-1);
          } else if(clickedPiece.icon().isNotEmpty && clickedPiece.side == gameHandler.currentTurn) {
            // Set the selected piece index
            setSelectedPieceIndex(index);
            gameHandler.canMoveAsPiece(selectedPieceIndex, -1);
          }
        });
        return GestureDetector(
          onTap: onCellClick,
          child: Container(
            width: 40, // Adjust the square size as per your requirement
            height: 40, // Adjust the square size as per your requirement
            decoration: BoxDecoration(border: border, color: color),
            child: Center(child: cellContent),
          ),
        );
      },
    );

    final gameLogTable = Table(
      border: TableBorder.all(
        color: Colors.black,
        width: 2,
        borderRadius: BorderRadius.all(Radius.elliptical(2, 3)),
      ),      
      defaultColumnWidth: IntrinsicColumnWidth(),
      children: [
        TableRow(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              child: Text('Turn'),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: Text('From'),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: Text('To'),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: Text('Taken'),
            ),
          ]
        )
      ]
    );

    int maxIndex = min(gameHandler.moveLogs.length, gameHandler.logStateIndex+1);
    for (var i = 0; i < maxIndex; i++) {
      final moveLog = gameHandler.moveLogs[i];

      final turn = formatChessSide(moveLog.$1);
      final moveFrom = indexToAlgebraicNotation(moveLog.$2);
      final moveTo = indexToAlgebraicNotation(moveLog.$3);

      gameLogTable.children.add(TableRow(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            child: Text(turn),
          ),
          Container(
            padding: EdgeInsets.all(4),
            child: Text(moveFrom),
          ),
          Container(
            padding: EdgeInsets.all(4),
            child: Text(moveTo),
          ),
          Container(
            padding: EdgeInsets.all(4),
            child: Text(moveLog.$4.toString()),
          ),
        ]
      ));
    }

    final actionButtons = Row(children: []);
    final startButton = Padding(
      padding: EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () => setState(() {
          startGame();
        }),
        child: Text('Start'),
      )
    );
    final undoButton = Padding(
      padding: EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () => setState(() {
          gameHandler.undoLastMove();
        }),
        child: Text('Undo'),
      ),
    );
    final restartButton = Padding(
      padding: EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () => setState(() {
          restartGameConfirm(context);
        }),
        child: Text('Restart'),
      ),
    );

    if (gameHandler.currentTurn == null ) { actionButtons.children.add(startButton); }
    else { actionButtons.children.add(restartButton); }

    if (gameHandler.logStateIndex >= 0) {
      actionButtons.children.add(undoButton);
    }


    Column gameStateColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Current turn: ${formatChessSide(gameHandler.currentTurn)}"),
        actionButtons,
        Container(
          margin: EdgeInsets.fromLTRB(0, 10, 0, 101),
          child: gameLogTable
        )
      ],
    );

    return Center(
      child: Row(
        children: [
          AspectRatio(aspectRatio: 1, child: chessGrid),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: gameStateColumn,
          ),
        ]
      ) 
    );
  }
}
