import 'dart:math' as math;

class MathUtils {
  static math.Random _random = math.Random();

  static int randomNumberWithinRangeInclusive(int min, int max) =>
      min + _random.nextInt(++max - min);

  static int randomNumberWithinRangeInclusiveFromZero(int max) =>
      _random.nextInt(++max);
}
