import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shifo_radar/app.dart';

void main() {
  testWidgets('App boots and shows the hospital list page',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ShifoRadarApp()),
    );

    // Allow async repository to settle.
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Shifo-Radar'), findsWidgets);
  });
}
