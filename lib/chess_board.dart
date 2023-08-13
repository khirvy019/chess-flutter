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
        final row = index ~/ 8;
        final col = index % 8;
        final isWhite = (row + col) % 2 == 0;
        final color = isWhite ? Colors.white : Colors.black;
        final piece = gameHandler.chessPieces[index];
        final isSelected = selectedPieceIndex == index;

        Border? border;
        if (isSelected) border = Border.all(color: Colors.green, width: 4);
        if (movableTiles.contains(index)) border = Border.all(color: Colors.green, width: 4);

        return GestureDetector(
          onTap: () => setState(() {
            final clickedPiece = gameHandler.chessPieces[index];
            print("Clicked: ${clickedPiece.icon()}");
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
          }),
          child: Container(
            width: 40, // Adjust the square size as per your requirement
            height: 40, // Adjust the square size as per your requirement
            decoration: BoxDecoration(
              border: border,
              color: color,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text("$index", style: TextStyle(color: isWhite ? Colors.black : Colors.white)),
                  Text(
                    piece.icon(),
                    style: TextStyle(
                      fontSize: 32,
                      color: isWhite ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
      final moveFrom = indexToAlgebraicNotation(moveLog.$3);
      final moveTo = indexToAlgebraicNotation(moveLog.$2);

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
          print("Starting");
          gameHandler.toggleTurn();
          print("Current turn: ${gameHandler.currentTurn}");
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
