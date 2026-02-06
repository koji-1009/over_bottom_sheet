/// A Flutter widget that provides an always-visible, draggable bottom sheet.
///
/// ## Features
///
/// - Always visible bottom sheet with customizable size
/// - Multiple snap points for positioning
/// - Nested scroll support for scrollable content
/// - Programmatic control via controller
///
/// ## Usage
///
/// ```dart
/// import 'package:over_bottom_sheet/over_bottom_sheet.dart';
///
/// final controller = OverBottomSheetController();
///
/// OverBottomSheet(
///   controller: controller,
///   snapPoints: const [0.0, 0.5, 1.0],
///   sizeOption: const OverBottomSheetSizeOptionMix(
///     maxHeight: 0.8,
///     minHeight: 100,
///   ),
///   content: ListView.builder(...),
///   child: const Center(child: Text('Background')),
/// )
/// ```
library;

import 'dart:math';

import 'package:flutter/material.dart';

// region Size Options

/// Base class for specifying the size constraints of [OverBottomSheet].
///
/// The sheet animates between [minHeight] (closed) and [maxHeight] (open).
/// Use one of the following subclasses:
/// - [OverBottomSheetSizeOptionFix]: Fixed pixel values
/// - [OverBottomSheetSizeOptionRatio]: Ratio of parent size (0.0-1.0)
/// - [OverBottomSheetSizeOptionMix]: Auto-detect based on value (>1.0 = pixels, ≤1.0 = ratio)
@immutable
sealed class OverBottomSheetSizeOption {
  /// Creates a size option with the given constraints.
  const OverBottomSheetSizeOption({
    required this.maxWidth,
    required this.minWidth,
    required this.maxHeight,
    required this.minHeight,
  });

  /// Maximum width of the sheet.
  final double maxWidth;

  /// Minimum width of the sheet.
  final double minWidth;

  /// Maximum height of the sheet (fully open position).
  final double maxHeight;

  /// Minimum height of the sheet (closed position).
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

/// Size option using fixed pixel values.
///
/// Example:
/// ```dart
/// const OverBottomSheetSizeOptionFix(
///   maxHeight: 500,
///   minHeight: 100,
/// )
/// ```
@immutable
class OverBottomSheetSizeOptionFix extends OverBottomSheetSizeOption {
  /// Creates a size option with fixed pixel values.
  const OverBottomSheetSizeOptionFix({
    super.maxWidth = double.infinity,
    super.minWidth = 0.0,
    required super.maxHeight,
    required super.minHeight,
  });
}

/// Size option using ratios of the parent size.
///
/// Values should be between 0.0 and 1.0.
///
/// Example:
/// ```dart
/// const OverBottomSheetSizeOptionRatio(
///   maxHeight: 0.8,  // 80% of parent height
///   minHeight: 0.2,  // 20% of parent height
/// )
/// ```
@immutable
class OverBottomSheetSizeOptionRatio extends OverBottomSheetSizeOption {
  /// Creates a size option with ratio values.
  const OverBottomSheetSizeOptionRatio({
    super.maxWidth = double.infinity,
    super.minWidth = 0.0,
    required super.maxHeight,
    required super.minHeight,
  });
}

/// Size option that auto-detects whether to use fixed or ratio values.
///
/// Values > 1.0 are treated as fixed pixels.
/// Values ≤ 1.0 are treated as ratios of the parent size.
///
/// Example:
/// ```dart
/// const OverBottomSheetSizeOptionMix(
///   maxHeight: 0.8,  // 80% of parent height (ratio)
///   minHeight: 100,  // 100 pixels (fixed)
/// )
/// ```
@immutable
class OverBottomSheetSizeOptionMix extends OverBottomSheetSizeOption {
  /// Creates a size option with auto-detection.
  const OverBottomSheetSizeOptionMix({
    super.maxWidth = double.infinity,
    super.minWidth = 0.0,
    required super.maxHeight,
    required super.minHeight,
  });
}

// endregion

// region Controller

/// Type definition for animation handler callback.
typedef AnimationHandler =
    Future<void> Function(double ratio, {Duration? duration, Curve? curve});

/// Controller that manages the ratio of [OverBottomSheet] being displayed.
///
/// The ratio value ranges from 0.0 (closed) to 1.0 (fully open).
/// Use [animateTo], [open], and [close] to animate the sheet position.
///
/// Example:
/// ```dart
/// final controller = OverBottomSheetController();
///
/// // Listen to value changes
/// controller.addListener(() => print(controller.value));
///
/// // Animate to specific position
/// controller.animateTo(0.5);
///
/// // Open/close shortcuts
/// controller.open();
/// controller.close();
/// ```
class OverBottomSheetController extends ValueNotifier<double> {
  /// Creates a controller with the given initial [ratio].
  ///
  /// The ratio is clamped between 0.0 and 1.0.
  OverBottomSheetController({double ratio = 1.0})
    : super(ratio.clamp(0.0, 1.0));

  AnimationHandler? _animationHandler;

  /// Updates the ratio value immediately (no animation).
  ///
  /// The value is clamped between 0.0 and 1.0.
  void updateRatio(double ratio) {
    value = min(max(ratio, 0), 1);
  }

  /// Sets the animation handler callback.
  ///
  /// This is called internally by [OverBottomSheet] when the widget is mounted.
  /// **Do not call this directly** - it is exposed for testing purposes only.
  @visibleForTesting
  void setAnimationHandler(AnimationHandler? handler) {
    _animationHandler = handler;
  }

  /// Animates to a specific [ratio].
  ///
  /// If no animation handler is attached (widget not mounted),
  /// the ratio is updated immediately without animation.
  Future<void> animateTo(
    double ratio, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (_animationHandler != null) {
      await _animationHandler!(ratio, duration: duration, curve: curve);
    } else {
      updateRatio(ratio);
    }
  }

  /// Opens the sheet to the maximum size (ratio 1.0).
  Future<void> open({Duration? duration, Curve? curve}) async {
    await animateTo(1.0, duration: duration, curve: curve);
  }

  /// Closes the sheet to the minimum size (ratio 0.0).
  Future<void> close({Duration? duration, Curve? curve}) async {
    await animateTo(0.0, duration: duration, curve: curve);
  }
}

// endregion

// region Widget

/// Function to create a widget using the display ratio of [OverBottomSheet].
typedef RatioWidgetBuilder =
    Widget Function(BuildContext context, double ratio);

/// A widget that displays an always-visible, draggable bottom sheet.
///
/// Unlike the standard [BottomSheet], this widget is always visible and can be
/// dragged between multiple snap points. It supports nested scrolling within
/// the sheet content.
///
/// {@tool snippet}
/// ```dart
/// OverBottomSheet(
///   controller: controller,
///   snapPoints: const [0.0, 0.5, 1.0],
///   sizeOption: const OverBottomSheetSizeOptionMix(
///     maxHeight: 0.8,
///     minHeight: 100,
///   ),
///   content: ListView.builder(...),
///   child: const Center(child: Text('Background')),
/// )
/// ```
/// {@end-tool}
class OverBottomSheet extends StatefulWidget {
  /// Creates an always-visible bottom sheet.
  ///
  /// The [sizeOption] and [child] arguments are required.
  const OverBottomSheet({
    super.key,
    this.controller,
    required this.child,
    required this.sizeOption,
    this.header,
    this.headerBuilder,
    this.content,
    this.contentBuilder,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.velocityThreshold = 300.0,
    this.snapPoints = const [0.0, 1.0],
    this.handleNestedScroll = false,
  }) : assert(snapPoints.length >= 2, 'snapPoints must have at least 2 values');

  /// Controller for programmatic control of the sheet position.
  ///
  /// Use this to animate the sheet, listen to position changes, or read the
  /// current ratio. If not provided, an internal controller is used.
  final OverBottomSheetController? controller;

  /// The widget displayed behind the bottom sheet.
  final Widget child;

  /// Size constraints for the bottom sheet.
  ///
  /// Use [OverBottomSheetSizeOptionFix] for fixed pixel values,
  /// [OverBottomSheetSizeOptionRatio] for ratios, or
  /// [OverBottomSheetSizeOptionMix] for auto-detection.
  final OverBottomSheetSizeOption sizeOption;

  /// Static header widget displayed at the top of the sheet.
  ///
  /// If both [header] and [headerBuilder] are provided, [header] takes priority.
  final Widget? header;

  /// Builder for the header widget that receives the current ratio.
  final RatioWidgetBuilder? headerBuilder;

  /// Static content widget displayed in the sheet body.
  ///
  /// If both [content] and [contentBuilder] are provided, [content] takes priority.
  final Widget? content;

  /// Builder for the content widget that receives the current ratio.
  final RatioWidgetBuilder? contentBuilder;

  /// Background color of the bottom sheet.
  final Color? backgroundColor;

  /// Elevation of the bottom sheet.
  final double? elevation;

  /// Shape of the bottom sheet (e.g., rounded corners).
  final ShapeBorder? shape;

  /// Clip behavior for the sheet content.
  final Clip? clipBehavior;

  /// Velocity threshold for fling gesture detection.
  ///
  /// When the drag velocity exceeds this threshold, the sheet will animate
  /// to the next snap point in the direction of the fling.
  /// Defaults to 300.0.
  final double velocityThreshold;

  /// Positions where the sheet can snap to.
  ///
  /// Values must be between 0.0 (closed) and 1.0 (fully open).
  /// Must contain at least 2 values. Defaults to `[0.0, 1.0]`.
  final List<double> snapPoints;

  /// Whether to enable nested scroll handling.
  ///
  /// When true, the sheet content can scroll when the sheet is at its
  /// maximum position. Dragging down when content is at the top will
  /// move the sheet instead of scrolling.
  final bool handleNestedScroll;

  @override
  State<OverBottomSheet> createState() => _OverBottomSheetState();
}

class _OverBottomSheetState extends State<OverBottomSheet>
    with TickerProviderStateMixin {
  late final _innerController = OverBottomSheetController();
  AnimationController? _animationController;

  /// Cached sorted snap points to avoid sorting on every build.
  late List<double> _sortedSnaps;

  /// Tracks whether the content scroll is at the top.
  bool _isContentAtTop = true;

  OverBottomSheetController get _controller =>
      widget.controller ?? _innerController;

  /// Header widget - recreated on each build to properly handle
  /// context-dependent builders.
  Widget get _header =>
      widget.header ??
      ValueListenableBuilder<double>(
        valueListenable: _controller,
        builder: (context, value, child) =>
            widget.headerBuilder?.call(context, value) ??
            const SizedBox.shrink(),
      );

  /// Content widget - recreated on each build to properly handle
  /// context-dependent builders.
  Widget get _content =>
      widget.content ??
      ValueListenableBuilder<double>(
        valueListenable: _controller,
        builder: (context, value, child) =>
            widget.contentBuilder?.call(context, value) ??
            const SizedBox.shrink(),
      );

  void _updateSortedSnaps() {
    _sortedSnaps = List<double>.from(widget.snapPoints)..sort();
  }

  @override
  void initState() {
    super.initState();
    _controller.setAnimationHandler(_animateTo);
    _updateSortedSnaps();
  }

  @override
  void didUpdateWidget(covariant OverBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _innerController).setAnimationHandler(null);
      _controller.setAnimationHandler(_animateTo);
    }
    // Update cached snap points if changed
    if (widget.snapPoints != oldWidget.snapPoints) {
      _updateSortedSnaps();
    }
  }

  @override
  void dispose() {
    _controller.setAnimationHandler(null);
    _animationController?.dispose();
    _animationController = null;
    _innerController.dispose();
    super.dispose();
  }

  Future<void> _animateTo(
    double ratio, {
    Duration? duration,
    Curve? curve,
  }) async {
    // Stop any existing animation
    _animationController?.stop();
    _animationController?.removeListener(_onAnimationUpdate);
    _animationController?.dispose();

    // Create new animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: duration ?? const Duration(milliseconds: 250),
      value: _controller.value,
    );
    _animationController!.addListener(_onAnimationUpdate);

    await _animationController!.animateTo(
      ratio,
      curve: curve ?? Curves.easeOutQuad,
    );
  }

  void _onAnimationUpdate() {
    if (_animationController != null) {
      _controller.updateRatio(_animationController!.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    void moveSheet({required double base, required double dy}) {
      final ratio = _controller.value - dy / base;
      _controller.updateRatio(ratio);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final sheetConstraints = widget.sizeOption._boxConstraints(constraints);
        final base = sheetConstraints.maxHeight - sheetConstraints.minHeight;
        final maxSnap = _sortedSnaps.last;

        // Ensure base is not zero to avoid division by zero
        if (base <= 0) {
          return widget.child;
        }

        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            widget.child,
            ValueListenableBuilder<double>(
              valueListenable: _controller,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(0, (1 - value) * base),
                child: child,
              ),
              child: GestureDetector(
                onVerticalDragStart: (_) {
                  _animationController?.stop();
                },
                onVerticalDragUpdate: (details) {
                  // When handleNestedScroll is enabled:
                  // - If at max position and content not at top, don't move sheet
                  // - Otherwise, move sheet normally
                  if (widget.handleNestedScroll &&
                      _controller.value >= maxSnap &&
                      !_isContentAtTop) {
                    return;
                  }
                  moveSheet(base: base, dy: details.delta.dy);
                },
                onVerticalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  final currentValue = _controller.value;

                  double targetSnap;

                  // If velocity is high enough, fling to next snap point
                  if (velocity.abs() > widget.velocityThreshold) {
                    if (velocity < 0) {
                      // Swiping up - find next higher snap point
                      targetSnap = _sortedSnaps.firstWhere(
                        (s) => s > currentValue,
                        orElse: () => _sortedSnaps.last,
                      );
                    } else {
                      // Swiping down - find next lower snap point
                      targetSnap = _sortedSnaps.lastWhere(
                        (s) => s < currentValue,
                        orElse: () => _sortedSnaps.first,
                      );
                    }
                  } else {
                    // Snap to nearest
                    targetSnap = _sortedSnaps.reduce((a, b) {
                      return (currentValue - a).abs() < (currentValue - b).abs()
                          ? a
                          : b;
                    });
                  }

                  _animateTo(targetSnap);
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (widget.handleNestedScroll) {
                      // Track if content is at the top
                      _isContentAtTop = notification.metrics.pixels <= 0;
                    }
                    return false; // Don't consume the notification
                  },
                  child: BottomSheet(
                    constraints: sheetConstraints,
                    builder: (context) => Column(
                      children: [
                        _header,
                        Expanded(child: SizedBox.expand(child: _content)),
                      ],
                    ),
                    backgroundColor: widget.backgroundColor,
                    elevation: widget.elevation,
                    shape: widget.shape,
                    clipBehavior: widget.clipBehavior,
                    animationController: null,
                    enableDrag: false,
                    onClosing: () {},
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// endregion

// region Private Extensions

extension on OverBottomSheetSizeOption {
  BoxConstraints _boxConstraints(BoxConstraints constraints) => switch (this) {
    OverBottomSheetSizeOptionFix(
      maxWidth: final maxWidth,
      minWidth: final minWidth,
      maxHeight: final maxHeight,
      minHeight: final minHeight,
    ) =>
      BoxConstraints(
        maxWidth: maxWidth,
        minWidth: minWidth,
        maxHeight: maxHeight,
        minHeight: minHeight,
      ),
    OverBottomSheetSizeOptionRatio(
      maxWidth: final maxWidth,
      minWidth: final minWidth,
      maxHeight: final maxHeight,
      minHeight: final minHeight,
    ) =>
      BoxConstraints(
        maxWidth: constraints.maxWidth * maxWidth,
        minWidth: constraints.maxWidth * minWidth,
        maxHeight: constraints.maxHeight * maxHeight,
        minHeight: constraints.maxHeight * minHeight,
      ),
    OverBottomSheetSizeOptionMix(
      maxWidth: final maxWidth,
      minWidth: final minWidth,
      maxHeight: final maxHeight,
      minHeight: final minHeight,
    ) =>
      BoxConstraints(
        maxWidth: maxWidth > 1.0 ? maxWidth : constraints.maxWidth * maxWidth,
        minWidth: minWidth > 1.0 ? minWidth : constraints.maxWidth * minWidth,
        maxHeight: maxHeight > 1.0
            ? maxHeight
            : constraints.maxHeight * maxHeight,
        minHeight: minHeight > 1.0
            ? minHeight
            : constraints.maxHeight * minHeight,
      ),
  };
}

// endregion
