## 1.0.0

* **BREAKING**: Removed `OverBottomSheetSizeOption` classes (`Fix`, `Ratio`, `Mix`).
* **BREAKING**: Replaced `sizeOption` with direct `maxHeight` and `minHeight` properties.
* **BREAKING**: Removed `snapThreshold` property, replaced with `snapPoints`.
* **BREAKING**: Consolidated all code into single `over_bottom_sheet.dart` file.
* Added `width` property for PC/tablet width constraints.
* Added `showDragHandle` for Material 3 standard drag handle.
* Added `shadowColor` and `surfaceTintColor` for Material 3 theming.
* Added `snapPoints` for multiple snap positions (e.g., `[0.0, 0.5, 1.0]`).
* Added `handleNestedScroll` for content scroll/sheet drag conflict handling.
* Added `onDragStart`, `onDragEnd`, `onSnapComplete` callbacks for state monitoring.
* Added velocity-based fling to next snap point.
* Replaced `BottomSheet` with `Material` for better theme integration.
* Refactored controller to use callback pattern instead of state attachment.
* Improved animation system using Flutter's `AnimationController`.
* Achieved 100% test coverage.

## 0.0.2

* Fix example code.

## 0.0.1

* Initial release.
