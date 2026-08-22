import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo app renders the sheet and the background', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('OverBottomSheet Demo'), findsOneWidget);
    expect(find.text('Sheet Item 1'), findsOneWidget);
    expect(find.text('Background Item 1'), findsOneWidget);
  });
}
