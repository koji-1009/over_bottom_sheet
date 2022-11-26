import 'dart:math';

import 'package:flutter/material.dart';

class PanelController extends ChangeNotifier {}

class OverBottomSheet extends StatefulWidget {
  const OverBottomSheet({
    super.key,
    required this.child,
    required this.panel,
  });

  final Widget child;
  final Widget panel;

  @override
  State<OverBottomSheet> createState() => _OverlappedPanelState();
}

class _OverlappedPanelState extends State<OverBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(
        milliseconds: 250,
      ),
      reverseDuration: const Duration(
        milliseconds: 200,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: Curves.linear.transform(_animationController.value),
            child: child,
          ),
          child: BottomSheet(
            animationController: _animationController,
            onClosing: () {
              _animationController.reverse(from: 0.5);
            },
            onDragStart: (details) {
            },
            onDragEnd: (details, {required isClosing}) {
            },
            builder: (context) => widget.panel,
          ),
        ),
      ],
    );
  }
}
