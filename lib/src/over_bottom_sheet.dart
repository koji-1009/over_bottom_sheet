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
    required this.contentBuilder,
    required this.sizeOption,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.controller,
    this.headerBuilder,
  });

  final Widget child;
  final SheetWidgetBuilder contentBuilder;
  final OverBottomSheetSizeOption sizeOption;

  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;

  final OverBottomSheetController? controller;
  final SheetWidgetBuilder? headerBuilder;

  @override
  State<OverBottomSheet> createState() => _OverlappedPanelState();
}

class _OverlappedPanelState extends State<OverBottomSheet> {
  OverBottomSheetController? _innerController;

  OverBottomSheetController get _controller =>
      widget.controller ?? _innerController!;

  SheetWidgetBuilder get _builder =>
      widget.headerBuilder ?? (context, ratio) => const SizedBox.shrink();

  Widget get _header => ValueListenableBuilder<double>(
        valueListenable: _controller,
        builder: (context, value, child) => _builder(
          context,
          value,
        ),
      );

  Widget get _content => ValueListenableBuilder<double>(
    valueListenable: _controller,
    builder: (context, value, child) => widget.contentBuilder(
      context,
      value,
    ),
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
                  constraints: widget.sizeOption.when(
                    fix: (_, __, maxWidth, minWidth) => BoxConstraints(
                      maxWidth: maxWidth,
                      minWidth: minWidth,
                    ),
                    ratio: (_, __, maxWidth, minWidth) => BoxConstraints(
                      maxWidth: constraints.maxWidth * maxWidth,
                      minWidth: constraints.maxWidth * minWidth,
                    ),
                    mix: (_, __, maxWidth, minWidth) => BoxConstraints(
                      maxWidth: maxWidth > 1.0
                          ? maxWidth
                          : constraints.maxWidth * maxWidth,
                      minWidth: minHeight > 1.0
                          ? minHeight
                          : constraints.maxWidth * minWidth,
                    ),
                  ),
                  onClosing: () {},
                  builder: (context) => SizedBox(
                    height: maxHeight,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: _header,
                        ),
                        Expanded(
                          child: SizedBox.expand(
                            child: _content,
                          ),
                        ),
                      ],
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

  void _moveSheet({
    required double distance,
    required double dy,
  }) {
    final ratio = _controller.value - dy / distance;
    _controller.updateRatio(ratio);
  }
}
