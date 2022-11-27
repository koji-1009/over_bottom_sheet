import 'package:flutter/material.dart';

class OverBottomSheet extends StatefulWidget {
  const OverBottomSheet({
    super.key,
    required this.child,
    required this.panel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.header,
    this.topSpace = 60,
    this.headerHeight = 60,
  });

  final Widget child;
  final Widget panel;

  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;

  final double topSpace;
  final double headerHeight;
  final Widget? header;

  @override
  State<OverBottomSheet> createState() => _OverlappedPanelState();
}

class _OverlappedPanelState extends State<OverBottomSheet> {
  late ValueNotifier<double> _controller;

  @override
  void initState() {
    _controller = ValueNotifier(
      widget.topSpace,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sheetHeight = constraints.maxHeight - widget.topSpace;
        final bottomEnd = sheetHeight - widget.headerHeight;

        _validateBounds(
          newPosition: _controller.value,
          bottomEnd: bottomEnd,
        );

        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            widget.child,
            ValueListenableBuilder<double>(
              valueListenable: _controller,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(0, value),
                child: child,
              ),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  final newPosition = _controller.value + details.delta.dy;

                  _validateBounds(
                    newPosition: newPosition,
                    bottomEnd: bottomEnd,
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
                    height: sheetHeight,
                    child: Column(
                      children: [
                        SizedBox(
                          height: widget.headerHeight,
                          width: double.infinity,
                          child: widget.header,
                        ),
                        Expanded(
                          child: SizedBox.expand(
                            child: widget.panel,
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

  void _validateBounds({
    required double newPosition,
    required double bottomEnd,
  }) {
    if (newPosition <= widget.topSpace) {
      _controller.value = widget.topSpace;
    } else if (newPosition >= bottomEnd) {
      _controller.value = bottomEnd;
    } else {
      _controller.value = newPosition;
    }
  }
}
