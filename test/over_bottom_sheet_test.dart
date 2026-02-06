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
              header: const SizedBox(height: 50),
              content: const SizedBox(),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Drag to 0.4 (240px down from 1.0)
      await tester.drag(find.byType(BottomSheet), const Offset(0, 240));
      await tester.pump();
      expect(controller.value, closeTo(0.4, 0.05));

      // Release -> snaps to nearest (0.0)
      await tester.pumpAndSettle();
      expect(controller.value, 0.0);
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
}
