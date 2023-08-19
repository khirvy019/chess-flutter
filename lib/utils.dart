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
