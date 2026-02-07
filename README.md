# OverBottomSheet

A Flutter widget that provides an always-visible, draggable bottom sheet with multiple snap points and nested scroll support.

[![pub package](https://img.shields.io/pub/v/over_bottom_sheet.svg)](https://pub.dev/packages/over_bottom_sheet)

## Features

* Always-visible bottom sheet overlay
* Multiple snap points (e.g., closed, half-open, full)
* Velocity-based fling gestures
* Nested scroll handling (scrollable content inside sheet)
* State callbacks (`onDragStart`, `onDragEnd`, `onSnapComplete`)
* Flexible size options (fixed, ratio, or mixed)
* `ValueNotifier`-based controller for reactive updates

## Usage

### Basic Example

```dart
import 'package:over_bottom_sheet/over_bottom_sheet.dart';

final controller = OverBottomSheetController();

OverBottomSheet(
  controller: controller,
  sizeOption: const OverBottomSheetSizeOptionMix(
    maxHeight: 0.8,
    minHeight: 100,
  ),
  header: const Text('Header'),
  content: ListView.builder(
    itemCount: 20,
    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  ),
  child: const Center(child: Text('Main Content')),
)
```

### Multiple Snap Points

```dart
OverBottomSheet(
  snapPoints: const [0.0, 0.5, 1.0], // closed, half, full
  // ...
)
```

### Nested Scroll Handling

Enable smooth scrolling inside the sheet content:

```dart
OverBottomSheet(
  handleNestedScroll: true,
  content: ListView.builder(...), // Scrollable content
  // ...
)
```

### State Callbacks

Monitor drag and snap events for UI synchronization (e.g., map camera):

```dart
OverBottomSheet(
  onDragStart: () {
    // User started dragging
  },
  onDragEnd: (targetRatio) {
    // User released, will snap to targetRatio
  },
  onSnapComplete: (ratio) {
    // Animation finished at ratio
  },
  // ...
)
```

### Controller Methods

```dart
// Animate to specific position
controller.animateTo(0.5);

// Open/close shortcuts
controller.open();
controller.close();

// Listen to value changes
controller.addListener(() => print(controller.value));
```

## Size Options

| Option                           | Description                              |
| -------------------------------- | ---------------------------------------- |
| `OverBottomSheetSizeOptionFix`   | Fixed pixel values                       |
| `OverBottomSheetSizeOptionRatio` | Ratio of parent size (0.0-1.0)           |
| `OverBottomSheetSizeOptionMix`   | Auto-detect: >1.0 = pixels, ≤1.0 = ratio |

## API Reference

See the [API documentation](https://pub.dev/documentation/over_bottom_sheet/latest/) for detailed information.

### OverBottomSheet

| Property                     | Type                         | Description                                |
| ---------------------------- | ---------------------------- | ------------------------------------------ |
| `controller`                 | `OverBottomSheetController?` | Controls sheet position                    |
| `sizeOption`                 | `OverBottomSheetSizeOption`  | Size constraints (required)                |
| `snapPoints`                 | `List<double>`               | Snap positions (default: `[0.0, 1.0]`)     |
| `handleNestedScroll`         | `bool`                       | Enable nested scroll handling              |
| `velocityThreshold`          | `double`                     | Fling detection threshold (default: 300.0) |
| `onDragStart`                | `VoidCallback?`              | Called when drag begins                    |
| `onDragEnd`                  | `void Function(double)?`     | Called with target snap ratio              |
| `onSnapComplete`             | `void Function(double)?`     | Called after snap animation completes      |
| `header` / `headerBuilder`   | `Widget` / `Function`        | Header widget                              |
| `content` / `contentBuilder` | `Widget` / `Function`        | Sheet content                              |
| `child`                      | `Widget`                     | Background content (required)              |

## License

MIT License - see [LICENSE](LICENSE) for details.
