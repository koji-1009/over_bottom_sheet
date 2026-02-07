import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:over_bottom_sheet/over_bottom_sheet.dart';

void main() {
  group('OverBottomSheetSizeOption', () {
    test('equality works correctly', () {
      const option1 = OverBottomSheetSizeOptionFix(
        maxHeight: 500,
        minHeight: 100,
      );
      const option2 = OverBottomSheetSizeOptionFix(
        maxHeight: 500,
        minHeight: 100,
      );
      const option3 = OverBottomSheetSizeOptionFix(
        maxHeight: 400,
        minHeight: 100,
      );

      expect(option1, equals(option2));
      expect(option1, isNot(equals(option3)));
    });

    test('hashCode is consistent with equality', () {
      const option1 = OverBottomSheetSizeOptionFix(
        maxHeight: 500,
        minHeight: 100,
      );
      const option2 = OverBottomSheetSizeOptionFix(
        maxHeight: 500,
        minHeight: 100,
      );
      const option3 = OverBottomSheetSizeOptionRatio(
        maxHeight: 500,
        minHeight: 100,
      );

      expect(option1.hashCode, equals(option2.hashCode));
      // Different types should have different hashCodes
      expect(option1.hashCode, isNot(equals(option3.hashCode)));
    });

    test('different types are not equal', () {
      const fix = OverBottomSheetSizeOptionFix(maxHeight: 500, minHeight: 100);
      const ratio = OverBottomSheetSizeOptionRatio(
        maxHeight: 500,
        minHeight: 100,
      );
      const mix = OverBottomSheetSizeOptionMix(maxHeight: 500, minHeight: 100);

      expect(fix, isNot(equals(ratio)));
      expect(fix, isNot(equals(mix)));
      expect(ratio, isNot(equals(mix)));
    });

    test('default width values are correct', () {
      const option = OverBottomSheetSizeOptionFix(
        maxHeight: 500,
        minHeight: 100,
      );

      expect(option.maxWidth, double.infinity);
      expect(option.minWidth, 0.0);
    });
  });

  group('OverBottomSheetController', () {
    test('initializes with default ratio', () {
      final controller = OverBottomSheetController();
      expect(controller.value, 1.0);
    });

    test('initializes with custom ratio', () {
      final controller = OverBottomSheetController(ratio: 0.5);
      expect(controller.value, 0.5);
    });

    test('updateRatio clamps value between 0.0 and 1.0', () {
      final controller = OverBottomSheetController();

      controller.updateRatio(1.5);
      expect(controller.value, 1.0);

      controller.updateRatio(-0.5);
      expect(controller.value, 0.0);

      controller.updateRatio(0.7);
      expect(controller.value, 0.7);
    });

    test('notifies listeners on value change', () {
      final controller = OverBottomSheetController(ratio: 0.0);
      var notified = false;
      controller.addListener(() => notified = true);

      controller.updateRatio(0.5);
      expect(notified, true);
    });
  });

  group('OverBottomSheet Widget', () {
    testWidgets('renders correctly', (tester) async {
      final controller = OverBottomSheetController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              header: const Text('Header'),
              content: const Text('Sheet Content'),
              child: const Text('Main Content'),
            ),
          ),
        ),
      );

      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Sheet Content'), findsOneWidget);
    });

    testWidgets('drag updates ratio', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              header: Container(height: 50, color: Colors.red),
              content: Container(height: 450, color: Colors.blue),
              child: const SizedBox(height: 800, width: 400),
            ),
          ),
        ),
      );

      expect(controller.value, 1.0);

      // Base: 500 - 100 = 400. Drag 200px -> ratio = 1.0 - (200/400) = 0.5
      await tester.drag(find.byType(BottomSheet), const Offset(0, 200));
      await tester.pump();

      expect(controller.value, closeTo(0.5, 0.05));
    });

    testWidgets('controller.open/close animates', (tester) async {
      final controller = OverBottomSheetController(ratio: 0.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      expect(controller.value, 0.0);

      controller.open();
      await tester.pumpAndSettle();
      expect(controller.value, 1.0);

      controller.close();
      await tester.pumpAndSettle();
      expect(controller.value, 0.0);
    });

    testWidgets('animateTo moves to specific ratio', (tester) async {
      final controller = OverBottomSheetController(ratio: 0.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 0.3, 0.7, 1.0],
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      controller.animateTo(0.7);
      await tester.pumpAndSettle();
      expect(controller.value, 0.7);

      controller.animateTo(0.3);
      await tester.pumpAndSettle();
      expect(controller.value, 0.3);
    });

    testWidgets('OverBottomSheetSizeOptionFix uses fixed values', (
      tester,
    ) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              width: 400,
              child: OverBottomSheet(
                controller: controller,
                sizeOption: const OverBottomSheetSizeOptionFix(
                  maxHeight: 300,
                  minHeight: 100,
                ),
                header: const SizedBox(height: 50),
                content: const SizedBox(),
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      );

      // Base = 300 - 100 = 200. Drag 100px -> ratio = 1.0 - (100/200) = 0.5
      await tester.drag(find.byType(BottomSheet), const Offset(0, 100));
      await tester.pump();

      expect(controller.value, closeTo(0.5, 0.05));
    });

    testWidgets(
      'OverBottomSheetSizeOptionRatio calculates correct constraints',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = OverBottomSheetController(ratio: 1.0);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OverBottomSheet(
                controller: controller,
                sizeOption: const OverBottomSheetSizeOptionRatio(
                  maxHeight: 0.5, // 800 * 0.5 = 400
                  minHeight: 0.1, // 800 * 0.1 = 80
                ),
                header: const SizedBox(height: 50),
                content: const SizedBox(),
                child: const SizedBox(),
              ),
            ),
          ),
        );

        final bottomSheet = tester.widget<BottomSheet>(
          find.byType(BottomSheet),
        );
        expect(bottomSheet.constraints!.maxHeight, 400);
        expect(bottomSheet.constraints!.minHeight, 80);
      },
    );

    testWidgets('OverBottomSheetSizeOptionMix calculates correct constraints', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionMix(
                maxHeight: 0.5, // Ratio -> 800 * 0.5 = 400
                minHeight: 100, // Fixed -> 100
              ),
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final bottomSheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(bottomSheet.constraints!.maxHeight, 400);
      expect(bottomSheet.constraints!.minHeight, 100);
    });

    testWidgets('OverBottomSheetSizeOptionMix handled Fix/Ratio combination', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionMix(
                maxHeight: 500, // Fixed -> 500
                minHeight: 0.1, // Ratio -> 80
              ),
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final bottomSheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(bottomSheet.constraints!.maxHeight, 500);
      expect(bottomSheet.constraints!.minHeight, 80);
    });

    testWidgets('handleNestedScroll prevents drag when content is not at top', (
      tester,
    ) async {
      final controller = OverBottomSheetController(ratio: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              handleNestedScroll: true,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              header: const SizedBox(height: 50),
              // Use a Builder to get context for dispatching notifications
              content: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      // Dispatch notification manually: Simulate NOT at top
                      ScrollUpdateNotification(
                        metrics: FixedScrollMetrics(
                          minScrollExtent: 0,
                          maxScrollExtent: 100,
                          pixels: 50, // Not 0
                          viewportDimension: 100,
                          axisDirection: AxisDirection.down,
                          devicePixelRatio: 1.0,
                        ),
                        context: context,
                        scrollDelta: 0,
                        depth: 0,
                      ).dispatch(context);
                    },
                    onLongPress: () {
                      // Dispatch notification manually: Simulate AT top
                      ScrollUpdateNotification(
                        metrics: FixedScrollMetrics(
                          minScrollExtent: 0,
                          maxScrollExtent: 100,
                          pixels: 0, // At top
                          viewportDimension: 100,
                          axisDirection: AxisDirection.down,
                          devicePixelRatio: 1.0,
                        ),
                        context: context,
                        scrollDelta: 0,
                        depth: 0,
                      ).dispatch(context);
                    },
                    child: const Text(
                      'Tap to scroll down, Long Press to scroll top',
                    ),
                  );
                },
              ),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // 1. Simulate content scrolled (pixels = 50)
      await tester.tap(
        find.text('Tap to scroll down, Long Press to scroll top'),
      );
      await tester.pump();

      // Drag sheet down -> Should NOT move (consumed by "nested scroll")
      await tester.drag(find.byType(BottomSheet), const Offset(0, 50));
      await tester.pump();
      expect(controller.value, 1.0);

      // 2. Simulate content at top (pixels = 0)
      await tester.longPress(
        find.text('Tap to scroll down, Long Press to scroll top'),
      );
      await tester.pump();

      // Drag sheet down -> Should move
      await tester.drag(find.byType(BottomSheet), const Offset(0, 50));
      await tester.pump();
      expect(controller.value, lessThan(1.0));
    });

    testWidgets('updates controller and snap points when widget changes', (
      tester,
    ) async {
      final controller1 = OverBottomSheetController();
      final controller2 = OverBottomSheetController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller1,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 1.0],
              header: const SizedBox(),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Change controller and snap points
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller2,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 0.5, 1.0],
              header: const SizedBox(),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Allow animations to settle/dispose
      await tester.pumpAndSettle();

      // Verify controller2 is active (changing value should update UI not directly testable easily without finding RenderObject, but we verify no crash and state update)
      controller2.updateRatio(0.5);
      await tester.pump();
      // Indirect verification: no errors thrown during swap
    });
  });

  group('Snap Behavior', () {
    testWidgets('snaps to nearest on drag end', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 0.5, 1.0],
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Drag from 1.0 to ~0.6 (160px down)
      // 1.0=500, 0.5=300 (diff 200). 0.6 is closer to 0.5.
      await tester.drag(find.byType(BottomSheet), const Offset(0, 160));
      await tester.pump();
      // Should be around 0.6
      expect(controller.value, closeTo(0.6, 0.1));

      // Release -> snaps to nearest (0.5)
      await tester.pumpAndSettle();
      expect(controller.value, 0.5);
    });

    testWidgets('snaps to multiple points', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 0.5, 1.0],
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Drag from 1.0 to 0.6 (160px down)
      await tester.drag(find.byType(BottomSheet), const Offset(0, 160));
      await tester.pump();
      expect(controller.value, closeTo(0.6, 0.05));

      // Release -> snaps to nearest (0.5)
      await tester.pumpAndSettle();
      expect(controller.value, 0.5);
    });

    testWidgets('fling down moves to next lower snap point', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 0.5, 1.0],
              velocityThreshold: 300.0,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Fling down with high velocity (should go to 0.5, not nearest)
      await tester.fling(find.byType(BottomSheet), const Offset(0, 50), 500);
      await tester.pumpAndSettle();

      expect(controller.value, 0.5);
    });

    testWidgets('fling up moves to next higher snap point', (tester) async {
      // Start from 0.5 (sheet is visible) to properly test fling up
      final controller = OverBottomSheetController(ratio: 0.5);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 0.5, 1.0],
              velocityThreshold: 300.0,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Fling up with high velocity (should go from 0.5 to 1.0)
      await tester.fling(find.byType(BottomSheet), const Offset(0, -50), 500);
      await tester.pumpAndSettle();

      expect(controller.value, 1.0);
    });
  });

  group('Edge Cases', () {
    testWidgets('handles zero base height gracefully', (tester) async {
      final controller = OverBottomSheetController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 100,
                minHeight: 100, // Same as max -> base = 0
              ),
              header: const SizedBox(),
              content: const SizedBox(),
              child: const Text('Child'),
            ),
          ),
        ),
      );

      // Should render child without error
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('works without external controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              header: const Text('Header'),
              content: const Text('Content'),
              child: const Text('Child'),
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
    });
  });

  group('State Callbacks', () {
    testWidgets('onDragStart is called when drag begins', (tester) async {
      var dragStartCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              onDragStart: () => dragStartCalled = true,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(BottomSheet), const Offset(0, 100));
      expect(dragStartCalled, true);
    });

    testWidgets('onDragEnd is called with target snap ratio', (tester) async {
      double? targetRatio;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              snapPoints: const [0.0, 0.5, 1.0],
              onDragEnd: (ratio) => targetRatio = ratio,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Drag from 1.0 to ~0.6, should snap to 0.5
      await tester.drag(find.byType(BottomSheet), const Offset(0, 160));
      await tester.pump();

      expect(targetRatio, 0.5);
    });

    testWidgets('onSnapComplete is called after animation finishes', (
      tester,
    ) async {
      double? completedRatio;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              sizeOption: const OverBottomSheetSizeOptionFix(
                maxHeight: 500,
                minHeight: 100,
              ),
              onSnapComplete: (ratio) => completedRatio = ratio,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Drag and release
      await tester.drag(find.byType(BottomSheet), const Offset(0, 200));
      await tester.pump();

      // Not called yet (animation in progress)
      expect(completedRatio, isNull);

      // Wait for animation to complete
      await tester.pumpAndSettle();

      // Now it should be called
      expect(completedRatio, isNotNull);
    });
  });
}
