import 'package:flutter/material.dart';
import 'package:over_bottom_sheet/src/over_bottom_sheet_controller.dart';

typedef HeaderBuilder = Widget Function(
  BuildContext context,
  double ratio,
);

class OverBottomSheet extends StatefulWidget {
  const OverBottomSheet({
    super.key,
    required this.child,
    required this.content,
    required this.headerHeight,
    required this.contentHeight,
    required this.minHeight,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.controller,
    this.headerBuilder,
  });

  final Widget child;
  final Widget content;

  final double headerHeight;
  final double contentHeight;
  final double minHeight;

  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;

  final OverBottomSheetController? controller;
  final HeaderBuilder? headerBuilder;

  @override
  State<OverBottomSheet> createState() => _OverlappedPanelState();
}

class _OverlappedPanelState extends State<OverBottomSheet> {
  OverBottomSheetController? _innerController;

  OverBottomSheetController get _controller =>
      widget.controller ?? _innerController!;

  double get _maxDistance =>
      widget.headerHeight + widget.contentHeight - widget.minHeight;

  HeaderBuilder get _builder =>
      widget.headerBuilder ?? (context, ratio) => const SizedBox.shrink();

  Widget get _header => widget.headerBuilder != null
      ? ValueListenableBuilder<double>(
          valueListenable: _controller,
          builder: (context, value, child) {
            return _builder(
              context,
              value,
            );
          },
        )
      : const SizedBox.shrink();

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
        _moveSheet(
          dy: 0,
        );

        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            widget.child,
            ValueListenableBuilder<double>(
              valueListenable: _controller,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(0, (1 - value) * _maxDistance),
                child: child,
              ),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  _moveSheet(
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
                  constraints: widget.constraints,
                  onClosing: () {},
                  builder: (context) => SizedBox(
                    height: widget.headerHeight + widget.contentHeight,
                    child: Column(
                      children: [
                        SizedBox(
                          height: widget.headerHeight,
                          width: double.infinity,
                          child: _header,
                        ),
                        Expanded(
                          child: SizedBox.expand(
                            child: widget.content,
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
    required double dy,
  }) {
    final ratio = _controller.value - dy / _maxDistance;
    _controller.updateRatio(ratio);
  }
}
