import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scale_ruler/flutter_scale_ruler.dart';

void main() {
  test('adds one to input values', () {
    final ruler = ScaleRuler.lengthMeasurement(
      maxValue: 8,
      minValue: 2,
      onChanged: (ScaleValue? scaleValue) {
        debugPrint("${scaleValue?.feet} Feet ${scaleValue?.inch} inches");
      },
    );
  });
}
