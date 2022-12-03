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
  final SheetWidgetBuilder? headerBuilder;
  final Widget? content;
  final SheetWidgetBuilder? contentBuilder;

  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;

  @override
  State<OverBottomSheet> createState() => _OverlappedPanelState();
}

class _OverlappedPanelState extends State<OverBottomSheet> {
  final _innerController = OverBottomSheetController();

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final sheetConstraints = widget.sizeOption.boxConstraints(constraints);
        final base = sheetConstraints.maxHeight - sheetConstraints.minHeight;
        _moveSheet(
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
                  _moveSheet(
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
                        child: _content,
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

  void _moveSheet({
    required double base,
    required double dy,
  }) {
    final ratio = _controller.value - dy / base;
    _controller.updateRatio(ratio);
  }
}

extension on OverBottomSheetSizeOption {
  BoxConstraints boxConstraints(BoxConstraints constraints) => when(
        fix: (maxWidth, minWidth, maxHeight, minHeight) => BoxConstraints(
          maxWidth: maxWidth,
          minWidth: minWidth,
          maxHeight: maxHeight,
          minHeight: minHeight,
        ),
        ratio: (maxWidth, minWidth, maxHeight, minHeight) => BoxConstraints(
          maxWidth: constraints.maxWidth * maxWidth,
          minWidth: constraints.maxWidth * minWidth,
          maxHeight: constraints.maxHeight * maxHeight,
          minHeight: constraints.maxHeight * minHeight,
        ),
        mix: (maxWidth, minWidth, maxHeight, minHeight) => BoxConstraints(
          maxWidth: maxWidth > 1.0 ? maxWidth : constraints.maxWidth * maxWidth,
          minWidth: minWidth > 1.0 ? minWidth : constraints.maxWidth * minWidth,
          maxHeight:
              maxHeight > 1.0 ? maxHeight : constraints.maxHeight * maxHeight,
          minHeight:
              minHeight > 1.0 ? minHeight : constraints.maxHeight * minHeight,
        ),
      );
}
