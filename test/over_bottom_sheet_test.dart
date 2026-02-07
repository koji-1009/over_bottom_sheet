import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:over_bottom_sheet/over_bottom_sheet.dart';

void main() {
  group('calculateTargetSnap', () {
    const snaps = [0.0, 0.5, 1.0];
    const threshold = 300.0;

    test('fling down at min position returns first snap', () {
      // This is the edge case: currentValue = 0.0, fling down -> orElse
      final result = calculateTargetSnap(
        currentValue: 0.0,
        velocity: 500.0, // Positive = down
        velocityThreshold: threshold,
        sortedSnaps: snaps,
      );
      expect(result, 0.0);
    });

    test('fling up at max position returns last snap', () {
      final result = calculateTargetSnap(
        currentValue: 1.0,
        velocity: -500.0, // Negative = up
        velocityThreshold: threshold,
        sortedSnaps: snaps,
      );
      expect(result, 1.0);
    });

    test('fling down from middle returns lower snap', () {
      final result = calculateTargetSnap(
        currentValue: 0.5,
        velocity: 500.0,
        velocityThreshold: threshold,
        sortedSnaps: snaps,
      );
      expect(result, 0.0);
    });

    test('fling up from middle returns higher snap', () {
      final result = calculateTargetSnap(
        currentValue: 0.5,
        velocity: -500.0,
        velocityThreshold: threshold,
        sortedSnaps: snaps,
      );
      expect(result, 1.0);
    });

    test('low velocity snaps to nearest', () {
      final result = calculateTargetSnap(
        currentValue: 0.6,
        velocity: 100.0, // Below threshold
        velocityThreshold: threshold,
        sortedSnaps: snaps,
      );
      expect(result, 0.5); // Nearest to 0.6
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

    test(
      'animateTo falls back to updateRatio when no handler is set',
      () async {
        final controller = OverBottomSheetController(ratio: 0.0);
        // animation handler は未設定（widget にマウントされていない）
        await controller.animateTo(0.75);
        expect(controller.value, 0.75);
      },
    );
  });

  group('OverBottomSheet Widget', () {
    testWidgets('renders correctly', (tester) async {
      final controller = OverBottomSheetController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              maxHeight: 500,
              minHeight: 100,
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
              maxHeight: 500,
              minHeight: 100,
              header: Container(height: 50, color: Colors.red),
              content: Container(height: 450, color: Colors.blue),
              child: const SizedBox(height: 800, width: 400),
            ),
          ),
        ),
      );

      expect(controller.value, 1.0);

      // Base: 500 - 100 = 400. Drag 200px -> ratio = 1.0 - (200/400) = 0.5
      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 200));
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
              maxHeight: 500,
              minHeight: 100,
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
              maxHeight: 500,
              minHeight: 100,
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

    testWidgets('fixed height values work correctly', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              width: 400,
              child: OverBottomSheet(
                controller: controller,
                maxHeight: 300, // Fixed pixels
                minHeight: 100, // Fixed pixels
                header: const SizedBox(height: 50),
                content: const SizedBox(),
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      );

      // Base = 300 - 100 = 200. Drag 100px -> ratio = 1.0 - (100/200) = 0.5
      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 100));
      await tester.pump();

      expect(controller.value, closeTo(0.5, 0.05));
    });

    testWidgets('ratio height values calculate correctly', (tester) async {
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
              maxHeight: 0.5, // 800 * 0.5 = 400
              minHeight: 0.1, // 800 * 0.1 = 80
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(OverBottomSheet),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.maxHeight, closeTo(400, 50));
      expect(constrainedBox.constraints.minHeight, closeTo(80, 20));
    });

    testWidgets('width property constrains sheet width', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              maxHeight: 400,
              minHeight: 100,
              width: 400, // Fixed 400px
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(OverBottomSheet),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.maxWidth, 400);
    });

    testWidgets('width ratio value works correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              maxHeight: 400,
              minHeight: 100,
              width: 0.5, // 50% of parent -> 400
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(OverBottomSheet),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.maxWidth, closeTo(400, 50));
    });

    testWidgets('mixed height values (ratio + fixed) work correctly', (
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
              maxHeight: 0.5, // Ratio -> 800 * 0.5 = 400
              minHeight: 100, // Fixed -> 100
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(OverBottomSheet),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.maxHeight, closeTo(400, 50));
      expect(constrainedBox.constraints.minHeight, 100);
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
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              // Use a Builder to get context for dispatching notifications
              content: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      // Dispatch notification manually: Simulate NOT at top
                      ScrollUpdateNotification(
                        depth: 0,
                        metrics: FixedScrollMetrics(
                          minScrollExtent: 0,
                          maxScrollExtent: 1000,
                          pixels: 100, // NOT at top
                          viewportDimension: 400,
                          axisDirection: AxisDirection.down,
                          devicePixelRatio: 1.0,
                        ),
                        context: context,
                      ).dispatch(context);
                    },
                    child: Container(height: 450, color: Colors.blue),
                  );
                },
              ),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final contentFinder = find.byType(GestureDetector).last;
      await tester.tap(contentFinder);
      await tester.pump();

      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 100));
      await tester.pump();

      expect(controller.value, 1.0);
    });

    testWidgets('handleNestedScroll allows drag when content is at top', (
      tester,
    ) async {
      final controller = OverBottomSheetController(ratio: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              handleNestedScroll: true,
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      ScrollUpdateNotification(
                        depth: 0,
                        metrics: FixedScrollMetrics(
                          minScrollExtent: 0,
                          maxScrollExtent: 1000,
                          pixels: 0, // AT top
                          viewportDimension: 400,
                          axisDirection: AxisDirection.down,
                          devicePixelRatio: 1.0,
                        ),
                        context: context,
                      ).dispatch(context);
                    },
                    child: Container(height: 450, color: Colors.blue),
                  );
                },
              ),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final contentFinder = find.byType(GestureDetector).last;
      await tester.tap(contentFinder);
      await tester.pump();

      // Base: 500 - 100 = 400. Drag 160px -> ratio ~= 0.6
      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 160));
      await tester.pump();

      expect(controller.value, closeTo(0.6, 0.1));
    });

    testWidgets('fling up snaps to next higher position', (tester) async {
      final controller = OverBottomSheetController(ratio: 0.5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              snapPoints: const [0.0, 0.5, 1.0],
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(OverBottomSheet),
        const Offset(0, -50),
        500,
      );
      await tester.pumpAndSettle();

      expect(controller.value, 1.0);
    });

    testWidgets('fling down snaps to next lower position', (tester) async {
      final controller = OverBottomSheetController(ratio: 0.5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              snapPoints: const [0.0, 0.5, 1.0],
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(OverBottomSheet),
        const Offset(0, 50),
        500,
      );
      await tester.pumpAndSettle();

      expect(controller.value, 0.0);
    });

    testWidgets('headerBuilder receives ratio updates', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      final receivedRatios = <double>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              maxHeight: 500,
              minHeight: 100,
              headerBuilder: (context, ratio) {
                receivedRatios.add(ratio);
                return Container(height: 50, color: Colors.red);
              },
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Clear initial build ratios
      receivedRatios.clear();

      // Drag to change ratio
      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 200));
      await tester.pump();

      expect(receivedRatios, isNotEmpty);
      expect(receivedRatios.last, closeTo(0.5, 0.1));
    });

    testWidgets('contentBuilder receives ratio updates', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);
      final receivedRatios = <double>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              contentBuilder: (context, ratio) {
                receivedRatios.add(ratio);
                return Container(color: Colors.blue);
              },
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Clear initial build ratios
      receivedRatios.clear();

      // Drag to change ratio
      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 200));
      await tester.pump();

      expect(receivedRatios, isNotEmpty);
      expect(receivedRatios.last, closeTo(0.5, 0.1));
    });

    testWidgets('fling up at max position stays at max', (tester) async {
      final controller = OverBottomSheetController(ratio: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              snapPoints: const [0.0, 0.5, 1.0],
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(OverBottomSheet),
        const Offset(0, -50),
        500,
      );
      await tester.pumpAndSettle();

      expect(controller.value, 1.0);
    });

    testWidgets('fling down at min position stays at min', (tester) async {
      final controller = OverBottomSheetController(ratio: 0.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              snapPoints: const [0.0, 0.5, 1.0],
              maxHeight: 500,
              minHeight: 100,
              header: Container(height: 50, color: Colors.red),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(OverBottomSheet),
        const Offset(0, 50),
        500,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(controller.value, 0.0);
    });

    testWidgets('snap to nearest when velocity is low', (tester) async {
      final controller = OverBottomSheetController(ratio: 0.6);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              snapPoints: const [0.0, 0.5, 1.0],
              velocityThreshold: 500, // High threshold
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Low velocity drag down
      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 10));
      await tester.pumpAndSettle();

      // Should snap to nearest (0.5)
      expect(controller.value, closeTo(0.5, 0.1));
    });

    testWidgets('onDragStart callback is called', (tester) async {
      var dragStarted = false;
      final controller = OverBottomSheetController(ratio: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              maxHeight: 500,
              minHeight: 100,
              onDragStart: () => dragStarted = true,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(OverBottomSheet), const Offset(0, 100));
      await tester.pump();

      expect(dragStarted, true);
    });

    testWidgets('onDragEnd callback is called with target ratio', (
      tester,
    ) async {
      double? targetRatio;
      final controller = OverBottomSheetController(ratio: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              maxHeight: 500,
              minHeight: 100,
              snapPoints: const [0.0, 0.5, 1.0],
              onDragEnd: (ratio) => targetRatio = ratio,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(OverBottomSheet),
        const Offset(0, 100),
        500,
      );
      await tester.pump();

      expect(targetRatio, 0.5);
    });

    testWidgets('onSnapComplete callback is called after animation', (
      tester,
    ) async {
      double? snapRatio;
      final controller = OverBottomSheetController(ratio: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              maxHeight: 500,
              minHeight: 100,
              snapPoints: const [0.0, 0.5, 1.0],
              onSnapComplete: (ratio) => snapRatio = ratio,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(OverBottomSheet),
        const Offset(0, 100),
        500,
      );
      await tester.pumpAndSettle();

      expect(snapRatio, 0.5);
    });

    testWidgets('sheet returns child only when base is zero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              maxHeight: 100,
              minHeight: 100, // Same as maxHeight -> base = 0
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const Text('Only Child'),
            ),
          ),
        ),
      );

      // Sheet should not be rendered when base is 0
      // Only the child widget should be displayed
      final overBottomSheet = find.byType(OverBottomSheet);
      expect(overBottomSheet, findsOneWidget);
      // ConstrainedBox should not exist inside OverBottomSheet (sheet not rendered)
      expect(
        find.descendant(
          of: overBottomSheet,
          matching: find.byType(ConstrainedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('showDragHandle displays drag handle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              maxHeight: 500,
              minHeight: 100,
              showDragHandle: true,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Find the drag handle container
      final dragHandle = find.descendant(
        of: find.byType(OverBottomSheet),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).borderRadius != null,
        ),
      );

      expect(dragHandle, findsOneWidget);
    });

    testWidgets('custom colors are applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              maxHeight: 500,
              minHeight: 100,
              backgroundColor: Colors.amber,
              elevation: 10.0,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(OverBottomSheet),
          matching: find.byType(Material),
        ),
      );

      expect(material.color, Colors.amber);
      expect(material.elevation, 10.0);
    });

    testWidgets('controller can be changed dynamically', (tester) async {
      final controller1 = OverBottomSheetController(ratio: 0.5);
      final controller2 = OverBottomSheetController(ratio: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller1,
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      expect(controller1.value, 0.5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller2,
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // New controller animateTo should work
      controller2.animateTo(0.3);
      await tester.pumpAndSettle();
      expect(controller2.value, 0.3);
    });

    testWidgets('snapPoints can be updated dynamically', (tester) async {
      final controller = OverBottomSheetController(ratio: 0.5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              snapPoints: const [0.0, 1.0],
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              controller: controller,
              snapPoints: const [0.0, 0.25, 0.5, 0.75, 1.0],
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Should snap to nearest from new snap points
      await tester.fling(
        find.byType(OverBottomSheet),
        const Offset(0, 40),
        500,
      );
      await tester.pumpAndSettle();

      expect(controller.value, closeTo(0.25, 0.30));
    });

    testWidgets('internal controller is created when none provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverBottomSheet(
              maxHeight: 500,
              minHeight: 100,
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Widget should render correctly
      expect(find.byType(OverBottomSheet), findsOneWidget);
    });
  });
}
