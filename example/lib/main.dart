import 'package:flutter/material.dart';
import 'package:over_bottom_sheet/over_bottom_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverBottomSheet Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = OverBottomSheetController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('OverBottomSheet Demo')),
      body: OverBottomSheet(
        controller: _controller,
        // Multiple snap points: closed, half, full
        snapPoints: const [0.0, 0.5, 1.0],
        // Enable nested scroll handling
        handleNestedScroll: true,
        maxHeight: 0.85,
        minHeight: 80,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: colorScheme.primaryContainer,
        elevation: 8,
        headerBuilder: (context, ratio) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ratio indicator
              Text(
                '${(ratio * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Control buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => _controller.animateTo(0.0),
                    tooltip: 'Close',
                  ),
                  IconButton(
                    icon: const Icon(Icons.unfold_less),
                    onPressed: () => _controller.animateTo(0.5),
                    tooltip: 'Half',
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () => _controller.animateTo(1.0),
                    tooltip: 'Open',
                  ),
                ],
              ),
            ],
          ),
        ),
        content: ListView.builder(
          primary: false,
          padding: const EdgeInsets.all(16),
          itemCount: 30,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text('${index + 1}'),
              ),
              title: Text('Sheet Item ${index + 1}'),
              subtitle: const Text('Scrollable content inside the sheet'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped item ${index + 1}')),
                );
              },
            ),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 50,
          itemBuilder: (context, index) => Card(
            color: colorScheme.secondaryContainer,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                'Background Item ${index + 1}',
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
              subtitle: Text(
                'This is the main content behind the sheet',
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Background: tapped ${index + 1}')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
