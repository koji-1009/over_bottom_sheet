## OverBottomSheet

Widget that always displays BottomSheet.

## Usage

```dart
final controller = OverBottomSheetController();

OverBottomSheet(
  clipBehavior: Clip.hardEdge,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(32),
      topRight: Radius.circular(32),
    ),
  ),
  sizeOption: const OverBottomSheetSizeOption.mix(
    maxHeight: 0.8,
    minHeight: 120,
    maxWidth: 0.8,
  ),
  controller: controller,
  headerBuilder: (context, ratio) => Center(
  child: Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<double>(
          valueListenable: controller,
          builder: (context, value, child) => IconButton(
            onPressed: () {
              if (value <= 0.5) {
                controller.open();
              } else {
                controller.close();
              }
            },
            icon: value >= 0.5
              ? const Icon(Icons.expand_more)
              : const Icon(Icons.expand_less),
            ),
          ),
          Text('ratio: ${ratio.toStringAsFixed(3)}'),
        ],
      ),
    ),
  ),
  content: ListView.builder(
    itemBuilder: (context, index) => ListTile(
      title: Text('sheet $index'),
    ),
  ),
  child: Container(
    color: Colors.indigo,
    child: ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text('main $index'),
      ),
    ),
  ),
),
```
