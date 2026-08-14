import 'package:flutter_test/flutter_test.dart';

import 'package:hydrotek_flutter/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HydrotekApp());
    await tester.pump();

    expect(find.text('Hydrotek Farm'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
