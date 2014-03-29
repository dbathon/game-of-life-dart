library game_of_life;

import "dart:math" show Random;

class GameOfLife {
  static final Random random = new Random();

  final int width, height;
  final bool wrapAround;
  List<bool> _cells;
  int version = 0;

  GameOfLife(this.width, this.height, [this.wrapAround = true]) {
    _cells = new List<bool>.filled(width * height, false);
  }

  int _toIndex(int x, int y) {
    if (wrapAround) {
      x = x % width;
      y = y % height;
    } else if (x < 0 || x >= width || y < 0 || y >= height) {
      return -1;
    }
    return y * width + x;
  }

  bool get(int x, int y) {
    int index = _toIndex(x, y);
    return index < 0 ? false : _cells[index];
  }

  void set(int x, int y, bool val) {
    int index = _toIndex(x, y);
    if (index >= 0) {
      _cells[index] = val;
      version += 1;
    }
  }

  void copyFrom(GameOfLife other) {
    for (int x = 0; x < width; ++x) {
      for (int y = 0; y < height; ++y) {
        set(x, y, other.get(x, y));
      }
    }
  }

  void randomCells(double probability) {
    for (int x = 0; x < width; ++x) {
      for (int y = 0; y < height; ++y) {
        set(x, y, random.nextDouble() <= probability);
      }
    }
  }

  int neighborCount(int x, int y) {
    int result = 0;

    result += get(x - 1, y - 1) ? 1 : 0;
    result += get(x + 0, y - 1) ? 1 : 0;
    result += get(x + 1, y - 1) ? 1 : 0;

    result += get(x - 1, y + 0) ? 1 : 0;

    result += get(x + 1, y + 0) ? 1 : 0;

    result += get(x - 1, y + 1) ? 1 : 0;
    result += get(x + 0, y + 1) ? 1 : 0;
    result += get(x + 1, y + 1) ? 1 : 0;

    return result;
  }

  GameOfLife nextState() {
    GameOfLife result = new GameOfLife(width, height, wrapAround);

    for (int x = 0; x < width; ++x) {
      for (int y = 0; y < height; ++y) {
        bool live = get(x, y);
        int nc = neighborCount(x, y);
        if (live) {
          result.set(x, y, nc == 2 || nc == 3);
        } else {
          result.set(x, y, nc == 3);
        }
      }
    }

    return result;
  }

}
