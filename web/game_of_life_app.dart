library game_of_life_app;

import "dart:html";
import 'dart:async';
import "game_of_life.dart";

import 'package:angular/angular.dart';
import 'package:di/di.dart';

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(targets: const ['game_of_life'], override: '*')
import 'dart:mirrors';

valueOrDefault(value, defaultValue) {
  return value != null ? value : defaultValue;
}

int intOrDefault(String str, int defaultValue) {
  if (str == null) {
    return defaultValue;
  } else {
    return int.parse(str, onError: (_) => defaultValue);
  }
}

@NgComponent(selector: "gol-renderer", template: """
<canvas></canvas>
""")
class GolRendererComponent implements NgShadowRootAware {

  Scope scope;

  @NgAttr("cell-size")
  String cellSize;

  @NgAttr("live-color")
  String liveColor;
  @NgAttr("dead-color")
  String deadColor;

  @NgOneWay("game")
  GameOfLife game;

  CanvasElement canvas;

  GolRendererComponent(this.scope);

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    canvas = shadowRoot.querySelector("canvas");

    canvas.onClick.listen(click);

    scope.watch('[game, game.version, cellSize, liveColor, liveColor]', (v, _)
        => draw(), context: this);
  }

  int getCellSize() => intOrDefault(this.cellSize, 10);

  draw() {
    if (game == null) {
      // TODO: draw something...
      return;
    }

    int cellSize = getCellSize();

    String liveColor = valueOrDefault(this.liveColor, "red");
    String deadColor = valueOrDefault(this.deadColor, "lightgrey");

    canvas.width = game.width * cellSize;
    canvas.height = game.height * cellSize;

    CanvasRenderingContext2D context = canvas.context2D;
    context.clearRect(0, 0, canvas.width, canvas.height);
    for (int x = 0; x < game.width; ++x) {
      for (int y = 0; y < game.height; ++y) {
        bool live = game.get(x, y);
        context
            ..fillStyle = live ? liveColor : deadColor
            ..fillRect(x * cellSize + 1, y * cellSize + 1, cellSize - 1,
                cellSize - 1);
      }
    }
  }

  click(MouseEvent e) {
    if (game != null) {
      int cellSize = getCellSize();
      int x = e.offset.x ~/ cellSize;
      int y = e.offset.y ~/ cellSize;
      game.set(x, y, !game.get(x, y));
    }
  }

}


@NgController(selector: "[gol-ctrl]", publishAs: "ctrl")
class AppController {
  GameOfLife game = new GameOfLife(60, 60, true);

  bool run = false;

  String cellSize = "10";

  AppController() {
    new Timer.periodic(new Duration(milliseconds: 50), (Timer) {
      if (run) {
        nextState();
      }
    });
  }

  void nextState() {
    game = game.nextState();
  }

  void random() {
    game.randomCells(0.5);
  }

  void clear() {
    game = new GameOfLife(60, 60, true);
  }

}


class AppModule extends Module {
  AppModule() {
    type(AppController);
    type(GolRendererComponent);
  }
}

void main() {
  ngBootstrap(module: new AppModule());
}
