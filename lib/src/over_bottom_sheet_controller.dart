import 'dart:math';

import 'package:flutter/foundation.dart';

class OverBottomSheetController extends ValueNotifier<double> {
  OverBottomSheetController({
    double ratio = 1.0,
  }) : super(ratio);

  void updateRatio(double ratio) {
    value = min(max(ratio, 0), 1);
  }

  void open() {
    updateRatio(1);
  }

  void close() {
    updateRatio(0);
  }
}
