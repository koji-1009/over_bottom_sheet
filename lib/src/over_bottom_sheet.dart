import 'package:flutter/material.dart';
import 'package:over_bottom_sheet/src/over_bottom_sheet_controller.dart';
import 'package:over_bottom_sheet/src/over_bottom_sheet_option.dart';

typedef SheetWidgetBuilder = Widget Function(
  BuildContext context,
  double ratio,
);

class OverBottomSheet extends StatefulWidget {
  const OverBottomSheet({
    super.key,
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
    this.controller,
  });

  final Widget child;
  final OverBottomSheetSizeOption sizeOption;

  final Widget? header;
  final SheetWidgetBuilder? headerBuilder;
  final Widget? content;
  final SheetWidgetBuilder? contentBuilder;

  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;

  final OverBottomSheetController? controller;

  @override
  State<OverBottomSheet> createState() => _OverlappedPanelState();
}

class _OverlappedPanelState extends State<OverBottomSheet> {
  OverBottomSheetController? _innerController;

  OverBottomSheetController get _controller =>
      widget.controller ?? _innerController!;

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
    if (widget.controller == null) {
      _innerController = OverBottomSheetController();
    }

    super.initState();
  }

  @override
  void dispose() {
    _innerController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = widget.sizeOption.when(
          fix: (maxHeight, _, __, ___) => maxHeight,
          ratio: (maxHeight, _, __, ___) => constraints.maxHeight * maxHeight,
          mix: (maxHeight, _, __, ___) =>
              maxHeight > 1.0 ? maxHeight : constraints.maxHeight * maxHeight,
        );
        final minHeight = widget.sizeOption.when(
          fix: (_, minHeight, __, ___) => minHeight,
          ratio: (_, minHeight, __, ___) => constraints.maxHeight * minHeight,
          mix: (_, minHeight, __, ___) =>
              minHeight > 1.0 ? minHeight : constraints.maxHeight * minHeight,
        );
        final maxWidth = widget.sizeOption.when(
          fix: (_, __, maxWidth, ___) => maxWidth,
          ratio: (_, __, maxWidth, ___) => constraints.maxWidth * maxWidth,
          mix: (_, __, maxWidth, ___) =>
              maxWidth > 1.0 ? maxWidth : constraints.maxWidth * maxWidth,
        );
        final minWidth = widget.sizeOption.when(
          fix: (_, __, ___, minWidth) => minWidth,
          ratio: (_, __, ___, minWidth) => constraints.maxHeight * minWidth,
          mix: (_, __, ___, minWidth) =>
              minWidth > 1.0 ? minWidth : constraints.maxHeight * minWidth,
        );

        final distance = maxHeight - minHeight;
        _moveSheet(
          distance: distance,
          dy: 0,
        );

        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            widget.child,
            ValueListenableBuilder<double>(
              valueListenable: _controller,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(0, (1 - value) * distance),
                child: child,
              ),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  _moveSheet(
                    distance: distance,
                    dy: details.delta.dy,
                  );
                },
                child: BottomSheet(
                  animationController: null,
                  enableDrag: false,
                  backgroundColor: widget.backgroundColor,
                  elevation: widget.elevation,
                  shape: widget.shape,
                  clipBehavior: widget.clipBehavior,
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                    minHeight: 0.0,
                    maxWidth: maxWidth,
                    minWidth: minWidth,
                  ),
                  onClosing: () {},
                  builder: (context) => Column(
                    children: [
                      _header,
                      Expanded(
                        child: _content,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _moveSheet({
    required double distance,
    required double dy,
  }) {
    final ratio = _controller.value - dy / distance;
    _controller.updateRatio(ratio);
  }
}
