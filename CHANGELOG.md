## 1.0.0

* **BREAKING**: Removed `snapThreshold` property, replaced with `snapPoints`.
* **BREAKING**: Consolidated all code into single `over_bottom_sheet.dart` file.
* Added `snapPoints` for multiple snap positions (e.g., `[0.0, 0.5, 1.0]`).
* Added `handleNestedScroll` for content scroll/sheet drag conflict handling.
* Added velocity-based fling to next snap point.
* Refactored controller to use callback pattern instead of state attachment.
* Improved animation system using Flutter's `AnimationController`.

## 0.0.2

* Fix example code.

## 0.0.1

* Initial release.
