## 1.0.1

* Fix `animateTo`, `open`, and `close` futures never completing when the animation is interrupted by another animation or by a drag.
* Fix the header and the drag handle being unable to move the sheet while `handleNestedScroll` is enabled and the content is scrolled away from the top.
* Fix nested and horizontal scrollables inside `content` being mistaken for the content scroll position when `handleNestedScroll` is enabled.
* Reuse a single `AnimationController` instead of creating and disposing one per animation.
* Add assertions for `maxHeight`, `minHeight`, `width`, `velocityThreshold`, and `snapPoints` values.
* Report a descriptive error when a ratio size is used inside a parent with unbounded height or width.
* Skip creating the internal controller when a `controller` is provided.
* Compare `snapPoints` by value so that an equal list does not trigger re-sorting.

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
