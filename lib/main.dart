import 'package:flutter/material.dart';
import 'chess_board.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chess'),
        ),
        body: Chessboard(),
      ),
    );
  }
}
