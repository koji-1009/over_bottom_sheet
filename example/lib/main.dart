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
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
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
        title: const Text('Flutter Demo Home Page'),
      ),
      body: OverBottomSheet(
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        contentHeight: 480,
        headerHeight: 60,
        minHeight: 60,
        controller: _controller,
        headerBuilder: (context, ratio) => Center(
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
        content: ListView.builder(
          itemBuilder: (context, index) => ListTile(
            title: Text('$index'),
          ),
        ),
        child: Container(
          color: Colors.indigo,
          child: const Center(
            child: Text('main area'),
          ),
        ),
      ),
    );
  }
}
