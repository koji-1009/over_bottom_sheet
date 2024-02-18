import 'package:over_bottom_sheet/src/over_bottom_sheet.dart';

/// Option to specify height and width of [OverBottomSheet].
sealed class OverBottomSheetSizeOption {
  const OverBottomSheetSizeOption({
    required this.maxWidth,
    required this.minWidth,
    required this.maxHeight,
    required this.minHeight,
  });

  final double maxWidth;
  final double minWidth;
  final double maxHeight;
  final double minHeight;

  @override
  int get hashCode =>
      Object.hash(runtimeType, maxWidth, minWidth, maxHeight, minHeight);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OverBottomSheetSizeOption &&
        other.maxWidth == maxWidth &&
        other.minWidth == minWidth &&
        other.maxHeight == maxHeight &&
        other.minHeight == minHeight;
  }
}

/// Specify the value of height and width.
class OverBottomSheetSizeOptionFix extends OverBottomSheetSizeOption {
  const OverBottomSheetSizeOptionFix({
    super.maxWidth = double.infinity,
    super.minWidth = 0.0,
    required super.maxHeight,
    required super.minHeight,
  });
}

/// Specify the ratio of height and width.
class OverBottomSheetSizeOptionRatio extends OverBottomSheetSizeOption {
  const OverBottomSheetSizeOptionRatio({
    super.maxWidth = double.infinity,
    super.minWidth = 0.0,
    required super.maxHeight,
    required super.minHeight,
  });
}

/// Use a mixture of [OverBottomSheetSizeOptionFix] and [OverBottomSheetSizeOptionRatio].
/// The size is defined as a ratio if it is less than 1.0,
/// and as a fix mode if it is greater than 1.0.
class OverBottomSheetSizeOptionMix extends OverBottomSheetSizeOption {
  const OverBottomSheetSizeOptionMix({
    super.maxWidth = double.infinity,
    super.minWidth = 0.0,
    required super.maxHeight,
    required super.minHeight,
  });
}
