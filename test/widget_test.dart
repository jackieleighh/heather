import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:heather/app/app.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HeatherApp()));
    // App should build (will show loading state since no location)
    expect(find.text('heather'), findsOneWidget);
  });
}
