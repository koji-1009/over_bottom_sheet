import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class OverBottomSheetController extends ValueNotifier<double> {
  OverBottomSheetController({
    double ratio = 1.0,
    this.period = const Duration(
      milliseconds: 8,
    ),
    this.step = 0.05,
  }) : super(ratio);

  final Duration period;
  final double step;

  void updateRatio(double ratio) {
    value = min(max(ratio, 0), 1);
  }

  void open() {
    final base = value;
    Timer.periodic(period, (timer) {
      final calc = base + timer.tick * step;
      if (calc >= 1) {
        timer.cancel();
        updateRatio(1);
        return;
      }

      updateRatio(calc);
    });
  }

  void close() {
    final base = value;
    Timer.periodic(period, (timer) {
      final calc = base - timer.tick * step;
      if (calc <= 0) {
        timer.cancel();
        updateRatio(0);
        return;
      }

      updateRatio(calc);
    });
  }
}
