/// A Flutter widget that provides an always-visible, draggable bottom sheet.
///
/// ## Features
///
/// - Always visible bottom sheet with customizable size
/// - Multiple snap points for positioning
/// - Nested scroll support for scrollable content
/// - Programmatic control via controller
/// - Material 3 theming support
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
///   maxHeight: 0.8,  // 80% of parent (ratio ≤1.0)
///   minHeight: 100,  // 100px (fixed >1.0)
///   content: ListView.builder(...),
///   child: const Center(child: Text('Background')),
/// )
/// ```
library;

import 'dart:math';

import 'package:flutter/material.dart';

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
/// Size values use auto-detection:
/// - Values > 1.0 are treated as fixed pixels
/// - Values ≤ 1.0 are treated as ratios of the parent size
///
/// {@tool snippet}
/// ```dart
/// OverBottomSheet(
///   controller: controller,
///   snapPoints: const [0.0, 0.5, 1.0],
///   maxHeight: 0.8,   // 80% of parent
///   minHeight: 100,   // 100 pixels
///   showDragHandle: true,
///   content: ListView.builder(...),
///   child: const Center(child: Text('Background')),
/// )
/// ```
/// {@end-tool}
class OverBottomSheet extends StatefulWidget {
  /// Creates an always-visible bottom sheet.
  const OverBottomSheet({
    super.key,
    this.controller,
    required this.child,
    required this.maxHeight,
    required this.minHeight,
    this.width,
    this.header,
    this.headerBuilder,
    this.content,
    this.contentBuilder,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.clipBehavior,
    this.showDragHandle,
    this.dragHandleColor,
    this.dragHandleSize,
    this.velocityThreshold = 300.0,
    this.snapPoints = const [0.0, 1.0],
    this.handleNestedScroll = false,
    this.onDragStart,
    this.onDragEnd,
    this.onSnapComplete,
  }) : assert(snapPoints.length >= 2, 'snapPoints must have at least 2 values');

  /// Controller for programmatic control of the sheet position.
  ///
  /// Use this to animate the sheet, listen to position changes, or read the
  /// current ratio. If not provided, an internal controller is used.
  final OverBottomSheetController? controller;

  /// The widget displayed behind the bottom sheet.
  final Widget child;

  /// Maximum height of the sheet (fully open position).
  ///
  /// Values > 1.0 are treated as fixed pixels.
  /// Values ≤ 1.0 are treated as ratios of the parent height.
  final double maxHeight;

  /// Minimum height of the sheet (closed position).
  ///
  /// Values > 1.0 are treated as fixed pixels.
  /// Values ≤ 1.0 are treated as ratios of the parent height.
  final double minHeight;

  /// Width of the sheet.
  ///
  /// If null, the sheet uses the full parent width.
  /// Values > 1.0 are treated as fixed pixels.
  /// Values ≤ 1.0 are treated as ratios of the parent width.
  final double? width;

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
  ///
  /// Defaults to [BottomSheetThemeData.backgroundColor],
  /// or [ColorScheme.surfaceContainerLow] if not specified.
  final Color? backgroundColor;

  /// Elevation of the bottom sheet.
  ///
  /// Defaults to [BottomSheetThemeData.elevation] or 1.0.
  final double? elevation;

  /// The color of the shadow below the sheet.
  ///
  /// Defaults to [BottomSheetThemeData.shadowColor] or transparent.
  final Color? shadowColor;

  /// The color used as an overlay on [backgroundColor] to indicate elevation.
  ///
  /// Defaults to [BottomSheetThemeData.surfaceTintColor] or transparent.
  final Color? surfaceTintColor;

  /// Shape of the bottom sheet (e.g., rounded corners).
  ///
  /// Defaults to [BottomSheetThemeData.shape].
  final ShapeBorder? shape;

  /// Clip behavior for the sheet content.
  ///
  /// Defaults to [BottomSheetThemeData.clipBehavior] or [Clip.none].
  final Clip? clipBehavior;

  /// Whether to show the standard drag handle at the top.
  ///
  /// Defaults to [BottomSheetThemeData.showDragHandle].
  final bool? showDragHandle;

  /// Color of the drag handle.
  ///
  /// Defaults to [BottomSheetThemeData.dragHandleColor] or onSurfaceVariant.
  final Color? dragHandleColor;

  /// Size of the drag handle.
  ///
  /// Defaults to [BottomSheetThemeData.dragHandleSize] or 32x4.
  final Size? dragHandleSize;

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

  /// Called when the user starts dragging the sheet.
  final VoidCallback? onDragStart;

  /// Called when the user stops dragging the sheet.
  ///
  /// The parameter is the snap point that the sheet will animate to.
  final void Function(double targetRatio)? onDragEnd;

  /// Called when the sheet finishes animating to a snap point.
  ///
  /// This is not called if the animation is interrupted by another drag
  /// or animation.
  final void Function(double ratio)? onSnapComplete;

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

  BoxConstraints _calculateConstraints(BoxConstraints constraints) {
    final maxH = widget.maxHeight > 1.0
        ? widget.maxHeight
        : constraints.maxHeight * widget.maxHeight;
    final minH = widget.minHeight > 1.0
        ? widget.minHeight
        : constraints.maxHeight * widget.minHeight;

    // Calculate width
    double maxW = constraints.maxWidth;
    if (widget.width != null) {
      maxW = widget.width! > 1.0
          ? widget.width!
          : constraints.maxWidth * widget.width!;
      // Clamp to parent width
      maxW = maxW.clamp(0.0, constraints.maxWidth);
    }

    return BoxConstraints(
      maxWidth: maxW,
      minWidth: maxW, // Use same value for fixed width
      maxHeight: maxH,
      minHeight: minH,
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSheetTheme = theme.bottomSheetTheme;

    final handleColor =
        widget.dragHandleColor ??
        bottomSheetTheme.dragHandleColor ??
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    final handleSize =
        widget.dragHandleSize ??
        bottomSheetTheme.dragHandleSize ??
        const Size(32, 4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: handleSize.width,
          height: handleSize.height,
          decoration: BoxDecoration(
            color: handleColor,
            borderRadius: BorderRadius.circular(handleSize.height / 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSheetTheme = theme.bottomSheetTheme;

    final showHandle =
        widget.showDragHandle ?? bottomSheetTheme.showDragHandle ?? false;

    void moveSheet({required double base, required double dy}) {
      final ratio = _controller.value - dy / base;
      _controller.updateRatio(ratio);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final sheetConstraints = _calculateConstraints(constraints);
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
                behavior: HitTestBehavior.translucent,
                onVerticalDragStart: (_) {
                  _animationController?.stop();
                  widget.onDragStart?.call();
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

                  final targetSnap = calculateTargetSnap(
                    currentValue: currentValue,
                    velocity: velocity,
                    velocityThreshold: widget.velocityThreshold,
                    sortedSnaps: _sortedSnaps,
                  );

                  widget.onDragEnd?.call(targetSnap);
                  _animateTo(targetSnap).then((_) {
                    widget.onSnapComplete?.call(targetSnap);
                  });
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (widget.handleNestedScroll) {
                      // Track if content is at the top
                      _isContentAtTop = notification.metrics.pixels <= 0;
                    }
                    return false; // Don't consume the notification
                  },
                  child: Material(
                    color:
                        widget.backgroundColor ??
                        bottomSheetTheme.backgroundColor ??
                        theme.colorScheme.surfaceContainerLow,
                    elevation:
                        widget.elevation ?? bottomSheetTheme.elevation ?? 1.0,
                    shadowColor:
                        widget.shadowColor ??
                        bottomSheetTheme.shadowColor ??
                        Colors.transparent,
                    surfaceTintColor:
                        widget.surfaceTintColor ??
                        bottomSheetTheme.surfaceTintColor ??
                        Colors.transparent,
                    shape: widget.shape ?? bottomSheetTheme.shape,
                    clipBehavior:
                        widget.clipBehavior ??
                        bottomSheetTheme.clipBehavior ??
                        Clip.none,
                    child: ConstrainedBox(
                      constraints: sheetConstraints,
                      child: Column(
                        children: [
                          if (showHandle) _buildDragHandle(context),
                          _header,
                          Expanded(child: SizedBox.expand(child: _content)),
                        ],
                      ),
                    ),
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

/// Calculates the target snap point based on current value and velocity.
///
/// This is extracted as a top-level function for testability.
@visibleForTesting
double calculateTargetSnap({
  required double currentValue,
  required double velocity,
  required double velocityThreshold,
  required List<double> sortedSnaps,
}) {
  // If velocity is high enough, fling to next snap point
  if (velocity.abs() > velocityThreshold) {
    if (velocity < 0) {
      // Swiping up - find next higher snap point
      return sortedSnaps.firstWhere(
        (s) => s > currentValue,
        orElse: () => sortedSnaps.last,
      );
    } else {
      // Swiping down - find next lower snap point
      return sortedSnaps.lastWhere(
        (s) => s < currentValue,
        orElse: () => sortedSnaps.first,
      );
    }
  } else {
    // Snap to nearest
    return sortedSnaps.reduce((a, b) {
      return (currentValue - a).abs() < (currentValue - b).abs() ? a : b;
    });
  }
}
