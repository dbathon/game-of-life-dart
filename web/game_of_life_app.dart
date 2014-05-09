library game_of_life_app;

import "dart:html";
import 'dart:async';
import "game_of_life.dart";

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:di/di.dart';


valueOrDefault(value, defaultValue) {
  return value != null ? value : defaultValue;
}

int intOrDefault(input, int defaultValue) {
  if (input == null) {
    return defaultValue;
  } else if (input is num) {
    return (input as num).toInt();
  } else {
    return num.parse(input.toString(), (_) => defaultValue).toInt();
  }
}

@Component(selector: "gol-renderer", template: """
<canvas></canvas>
""", exportExpressions: const
    ['[game, game.version, cellSize, liveColor, deadColor]'])
class GolRendererComponent implements ShadowRootAware {

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

  bool drawLive = null;

  GolRendererComponent(this.scope);

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    canvas = shadowRoot.querySelector("canvas");

    canvas.onMouseDown.listen(drawStart);
    canvas.onMouseMove.listen(drawMove);
    canvas.onMouseUp.listen(drawStop);
    canvas.onMouseLeave.listen(drawStop);

    scope.watch('[game, game.version, cellSize, liveColor, deadColor]', (v, _) => draw(), context: this);
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

    canvas.width = (game.width * cellSize) - 1;
    canvas.height = (game.height * cellSize) - 1;

    CanvasRenderingContext2D context = canvas.context2D;
    context.save();
    context.clearRect(0, 0, canvas.width, canvas.height);
    for (int x = 0; x < game.width; ++x) {
      for (int y = 0; y < game.height; ++y) {
        bool live = game.get(x, y);
        context
            ..fillStyle = live ? liveColor : deadColor
            ..fillRect(x * cellSize, y * cellSize, cellSize - 1, cellSize - 1);
      }
    }
    context.restore();
  }

  Point _extractPosition(MouseEvent e) {
    int cellSize = getCellSize();
    Rectangle clientRect = canvas.getBoundingClientRect();
    int x = (e.client.x - clientRect.left) ~/ cellSize;
    int y = (e.client.y - clientRect.top) ~/ cellSize;
    return new Point(x, y);
  }

  void drawStart(MouseEvent e) {
    if (game != null && e.button == 0) {
      Point pos = _extractPosition(e);
      drawLive = !game.get(pos.x, pos.y);
      game.set(pos.x, pos.y, drawLive);
    }
  }

  void drawMove(MouseEvent e) {
    if (game != null && drawLive != null) {
      Point pos = _extractPosition(e);
      game.set(pos.x, pos.y, drawLive);
    }
  }

  void drawStop(MouseEvent e) {
    drawLive = null;
  }

}


@Controller(selector: "[gol-ctrl]", publishAs: "ctrl", exportExpressions: const ['[size, wrapAround]',
    '[run, runDelay]'])
class AppController {
  num size = 60;
  bool wrapAround = true;

  GameOfLife game;

  bool run = false;
  num runDelay = 50;
  Timer currentTimer;

  num cellSize = 8;

  AppController(Scope scope) {
    clear();

    scope.watch('[size, wrapAround]', (v, _) {
      GameOfLife oldGame = game;
      clear();
      game.copyFrom(oldGame);
    }, context: this);

    scope.watch('[run, runDelay]', (v, _) {
      if (currentTimer != null) {
        currentTimer.cancel();
        currentTimer = null;
      }
      setupTimer();
    }, context: this);
  }

  setupTimer() {
    if (run) {
      currentTimer = new Timer(new Duration(milliseconds: runDelay.toInt()), () {
        currentTimer = null;
        if (run) {
          nextState();
          setupTimer();
        }
      });
    }
  }

  void nextState() {
    game = game.nextState();
  }

  void random() {
    game.randomCells(0.5);
  }

  void clear() {
    int size = intOrDefault(this.size, 60);
    game = new GameOfLife(size, size, wrapAround);
  }

}


class AppModule extends Module {
  AppModule() {
    type(AppController);
    type(GolRendererComponent);
  }
}

void main() {
  applicationFactory().addModule(new AppModule()).run();
}
