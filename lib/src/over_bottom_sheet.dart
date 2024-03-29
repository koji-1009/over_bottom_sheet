import 'package:flutter/material.dart';
import 'package:over_bottom_sheet/src/over_bottom_sheet_controller.dart';
import 'package:over_bottom_sheet/src/over_bottom_sheet_option.dart';

/// Function to create a widget using the display ratio of [OverBottomSheet].
typedef RatioWidgetBuilder = Widget Function(
  BuildContext context,
  double ratio,
);

/// Widget that always displays [BottomSheet].
class OverBottomSheet extends StatefulWidget {
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
  });

  final OverBottomSheetController? controller;

  final Widget child;
  final OverBottomSheetSizeOption sizeOption;

  final Widget? header;
  final RatioWidgetBuilder? headerBuilder;
  final Widget? content;
  final RatioWidgetBuilder? contentBuilder;

  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;

  @override
  State<OverBottomSheet> createState() => _OverlappedPanelState();
}

class _OverlappedPanelState extends State<OverBottomSheet> {
  late final _innerController = OverBottomSheetController();

  OverBottomSheetController get _controller =>
      widget.controller ?? _innerController;

  Widget get _header =>
      widget.header ??
      ValueListenableBuilder<double>(
        valueListenable: _controller,
        builder: (context, value, child) =>
            widget.headerBuilder?.call(context, value) ??
            const SizedBox.shrink(),
      );

  Widget get _content =>
      widget.content ??
      ValueListenableBuilder<double>(
        valueListenable: _controller,
        builder: (context, value, child) =>
            widget.contentBuilder?.call(context, value) ??
            const SizedBox.shrink(),
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void moveSheet({
      required double base,
      required double dy,
    }) {
      final ratio = _controller.value - dy / base;
      _controller.updateRatio(ratio);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final sheetConstraints = widget.sizeOption.boxConstraints(constraints);
        final base = sheetConstraints.maxHeight - sheetConstraints.minHeight;
        moveSheet(
          base: base,
          dy: 0,
        );

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
                onVerticalDragUpdate: (details) {
                  moveSheet(
                    base: base,
                    dy: details.delta.dy,
                  );
                },
                child: BottomSheet(
                  constraints: sheetConstraints,
                  builder: (context) => Column(
                    children: [
                      _header,
                      Expanded(
                        child: SizedBox.expand(
                          child: _content,
                        ),
                      ),
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
          ],
        );
      },
    );
  }
}

extension on OverBottomSheetSizeOption {
  BoxConstraints boxConstraints(
    BoxConstraints constraints,
  ) =>
      switch (this) {
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
            maxWidth:
                maxWidth > 1.0 ? maxWidth : constraints.maxWidth * maxWidth,
            minWidth:
                minWidth > 1.0 ? minWidth : constraints.maxWidth * minWidth,
            maxHeight:
                maxHeight > 1.0 ? maxHeight : constraints.maxHeight * maxHeight,
            minHeight:
                minHeight > 1.0 ? minHeight : constraints.maxHeight * minHeight,
          ),
      };
}
