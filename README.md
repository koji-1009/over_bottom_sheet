# OverBottomSheet

[![pub package](https://img.shields.io/pub/v/over_bottom_sheet.svg)](https://pub.dev/packages/over_bottom_sheet)
[![GitHub license](https://img.shields.io/github/license/koji-1009/over_bottom_sheet)](https://github.com/koji-1009/over_bottom_sheet/blob/main/LICENSE)
[![CI](https://github.com/koji-1009/over_bottom_sheet/actions/workflows/analyze.yaml/badge.svg)](https://github.com/koji-1009/over_bottom_sheet/actions/workflows/analyze.yaml)
[![codecov](https://codecov.io/gh/koji-1009/over_bottom_sheet/branch/main/graph/badge.svg)](https://codecov.io/gh/koji-1009/over_bottom_sheet)

A Flutter widget that provides an always-visible, draggable bottom sheet with multiple snap points and nested scroll support.

## Features

* Always-visible bottom sheet overlay
* Multiple snap points (e.g., closed, half-open, full)
* Velocity-based fling gestures
* Nested scroll handling (scrollable content inside sheet)
* State callbacks (`onDragStart`, `onDragEnd`, `onSnapComplete`)
* Flexible height/width constraints with auto-detect (>1.0 = pixels, ≤1.0 = ratio)
* Material 3 theming support (`showDragHandle`, `shadowColor`, `surfaceTintColor`)
* `ValueNotifier`-based controller for reactive updates

## Demo

![Live Demo](https://koji-1009.github.io/over_bottom_sheet/)

## Usage

### Basic Example

```dart
import 'package:over_bottom_sheet/over_bottom_sheet.dart';

final controller = OverBottomSheetController();

OverBottomSheet(
  controller: controller,
  maxHeight: 0.8,   // 80% of parent height
  minHeight: 100,   // 100px fixed
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

### Width Constraint (PC/Tablet)

```dart
OverBottomSheet(
  maxHeight: 0.8,
  minHeight: 100,
  width: 600,       // Fixed 600px (clamped to parent)
  // or
  width: 0.5,       // 50% of parent width
  // ...
)
```

### Drag Handle

```dart
OverBottomSheet(
  showDragHandle: true,  // Material 3 standard drag handle
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

## Size Constraints

Values are auto-detected:
- `> 1.0` → Fixed pixels
- `≤ 1.0` → Ratio of parent size

| Property    | Description                      |
| ----------- | -------------------------------- |
| `maxHeight` | Maximum sheet height (required)  |
| `minHeight` | Minimum sheet height (required)  |
| `width`     | Sheet width (optional, defaults to full width) |

## API Reference

See the [API documentation](https://pub.dev/documentation/over_bottom_sheet/latest/) for detailed information.

### OverBottomSheet

| Property                     | Type                         | Description                                |
| ---------------------------- | ---------------------------- | ------------------------------------------ |
| `controller`                 | `OverBottomSheetController?` | Controls sheet position                    |
| `maxHeight`                  | `double`                     | Max height (required)                      |
| `minHeight`                  | `double`                     | Min height (required)                      |
| `width`                      | `double?`                    | Sheet width (optional)                     |
| `snapPoints`                 | `List<double>`               | Snap positions (default: `[0.0, 1.0]`)     |
| `handleNestedScroll`         | `bool`                       | Enable nested scroll handling              |
| `velocityThreshold`          | `double`                     | Fling detection threshold (default: 300.0) |
| `showDragHandle`             | `bool?`                      | Show Material 3 drag handle                |
| `shadowColor`                | `Color?`                     | Sheet shadow color                         |
| `surfaceTintColor`           | `Color?`                     | Material 3 surface tint                    |
| `onDragStart`                | `VoidCallback?`              | Called when drag begins                    |
| `onDragEnd`                  | `void Function(double)?`     | Called with target snap ratio              |
| `onSnapComplete`             | `void Function(double)?`     | Called after snap animation completes      |
| `header` / `headerBuilder`   | `Widget` / `Function`        | Header widget                              |
| `content` / `contentBuilder` | `Widget` / `Function`        | Sheet content                              |
| `child`                      | `Widget`                     | Background content (required)              |

## License

MIT License - see [LICENSE](LICENSE) for details.
