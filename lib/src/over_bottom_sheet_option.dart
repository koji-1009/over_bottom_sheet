import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'over_bottom_sheet_option.freezed.dart';

@freezed
class OverBottomSheetSizeOption with _$OverBottomSheetSizeOption {
  const factory OverBottomSheetSizeOption.fix({
    required double maxHeight,
    required double minHeight,
    @Default(double.infinity) double maxWidth,
    @Default(0.0) double minWidth,
  }) = _OverBottomSheetSizeOptionFix;

  const factory OverBottomSheetSizeOption.ratio({
    required double maxHeight,
    required double minHeight,
    @Default(1.0) double maxWidth,
    @Default(0.0) double minWidth,
  }) = _OverBottomSheetSizeOptionRatio;

  const factory OverBottomSheetSizeOption.mix({
    required double maxHeight,
    required double minHeight,
    @Default(1.0) double maxWidth,
    @Default(0.0) double minWidth,
  }) = _OverBottomSheetSizeOptionMix;
}
