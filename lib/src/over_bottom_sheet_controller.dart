import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:over_bottom_sheet/src/over_bottom_sheet.dart';

/// Controller that manages the percentage of [OverBottomSheet] being drawn out.
class OverBottomSheetController extends ValueNotifier<double> {
  OverBottomSheetController({
    double ratio = 1.0,
    this.tick = const Duration(
      milliseconds: 8,
    ),
    this.step = 0.05,
  }) : super(ratio);

  final Duration tick;
  final double step;

  void updateRatio(double ratio) {
    value = min(max(ratio, 0), 1);
  }

  void open() {
    final base = value;
    Timer.periodic(tick, (timer) {
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
    Timer.periodic(tick, (timer) {
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
