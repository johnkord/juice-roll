import 'dart:math';

/// A seeded random for reproducible tests.
class SeededRandom implements Random {
  int _seed;

  SeededRandom(this._seed);

  @override
  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }

  @override
  double nextDouble() => nextInt(1 << 32) / (1 << 32);

  @override
  bool nextBool() => nextInt(2) == 1;
}
