import "dart:html";
import 'dart:async';
import "game_of_life.dart";

ButtonElement runStop = querySelector("#runStop");
ButtonElement random = querySelector("#random");
CanvasElement canvas = querySelector("#canvas");

GameOfLife current = new GameOfLife(60, 60, true);

int cellSize = 10;

void main() {
  runStop.onClick.listen((Event e) {
    current = current.nextState();
    drawCurrent();
  });

  random.onClick.listen((Event e) {
    current.randomCells(0.5);
    drawCurrent();
  });

  canvas.onClick.listen((MouseEvent e) {
    int x = e.offset.x ~/ cellSize;
    int y = e.offset.y ~/ cellSize;
    current.set(x, y, !current.get(x, y));

    drawCurrent();
  });

  new Timer.periodic(new Duration(milliseconds: 50), (Timer) {
    current = current.nextState();
    drawCurrent();
  });

  drawCurrent();
}

drawCurrent() {
  draw(canvas, current, cellSize, "red", "lightgrey");
}

draw(CanvasElement canvas, GameOfLife gameOfLife, int drawCellSize, String liveColor, String
    deadColor) {
  canvas.width = gameOfLife.width * drawCellSize;
  canvas.height = gameOfLife.height * drawCellSize;

  CanvasRenderingContext2D context = canvas.context2D;
  context.clearRect(0, 0, canvas.width, canvas.height);
  for (int x = 0; x < gameOfLife.width; ++x) {
    for (int y = 0; y < gameOfLife.height; ++y) {
      bool live = gameOfLife.get(x, y);
      context
          ..fillStyle = live ? liveColor : deadColor
          ..fillRect(x * drawCellSize + 1, y * drawCellSize + 1, drawCellSize -
              1, drawCellSize - 1);
    }
  }
}
