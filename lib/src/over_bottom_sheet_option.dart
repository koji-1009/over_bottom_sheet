import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:over_bottom_sheet/src/over_bottom_sheet.dart';

part 'over_bottom_sheet_option.freezed.dart';

/// Option to specify height and width of [OverBottomSheet].
@freezed
class OverBottomSheetSizeOption with _$OverBottomSheetSizeOption {
  /// Specify the value of height and width.
  const factory OverBottomSheetSizeOption.fix({
    @Default(double.infinity) double maxWidth,
    @Default(0.0) double minWidth,
    required double maxHeight,
    required double minHeight,
  }) = _OverBottomSheetSizeOptionFix;

  /// Specify the ratio of height and width.
  const factory OverBottomSheetSizeOption.ratio({
    @Default(double.infinity) double maxWidth,
    @Default(0.0) double minWidth,
    required double maxHeight,
    required double minHeight,
  }) = _OverBottomSheetSizeOptionRatio;

  /// Use a mixture of [OverBottomSheetSizeOption.fix] and
  /// [OverBottomSheetSizeOption.ratio].
  /// The size is defined as a ratio if it is less than 1.0,
  /// and as a fix mode if it is greater than 1.0.
  const factory OverBottomSheetSizeOption.mix({
    @Default(double.infinity) double maxWidth,
    @Default(0.0) double minWidth,
    required double maxHeight,
    required double minHeight,
  }) = _OverBottomSheetSizeOptionMix;
}
