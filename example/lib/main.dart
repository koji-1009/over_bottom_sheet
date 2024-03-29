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
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: OverBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        sizeOption: const OverBottomSheetSizeOptionMix(
          maxHeight: 0.8,
          minHeight: 120,
          maxWidth: 0.8,
        ),
        controller: _controller,
        headerBuilder: (context, ratio) => Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: _controller,
                  builder: (context, value, child) => IconButton(
                    onPressed: () {
                      if (value <= 0.5) {
                        _controller.open();
                      } else {
                        _controller.close();
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
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('sheet $index'),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 200,
          itemBuilder: (context, index) => Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              title: Text(
                'main $index',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Background: tapped $index'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
