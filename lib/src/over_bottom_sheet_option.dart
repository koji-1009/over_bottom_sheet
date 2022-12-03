import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'over_bottom_sheet_option.freezed.dart';

@freezed
class OverBottomSheetSizeOption with _$OverBottomSheetSizeOption {
  const factory OverBottomSheetSizeOption.fix({
    @Default(double.infinity) double maxWidth,
    @Default(0.0) double minWidth,
    required double maxHeight,
    required double minHeight,
  }) = _OverBottomSheetSizeOptionFix;

  const factory OverBottomSheetSizeOption.ratio({
    @Default(double.infinity) double maxWidth,
    @Default(0.0) double minWidth,
    required double maxHeight,
    required double minHeight,
  }) = _OverBottomSheetSizeOptionRatio;

  const factory OverBottomSheetSizeOption.mix({
    @Default(double.infinity) double maxWidth,
    @Default(0.0) double minWidth,
    required double maxHeight,
    required double minHeight,
  }) = _OverBottomSheetSizeOptionMix;
}
