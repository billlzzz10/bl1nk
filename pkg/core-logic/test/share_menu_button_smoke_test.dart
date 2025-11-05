import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import target via relative path since sources are outside lib/
import '../plugin_registry/shared/share/_shared.dart';

void main() {
  testWidgets('ShareMenuButton renders a FilledButton', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShareMenuButton(),
        ),
      ),
    );

    // Whether feature flag is on or off, the button should render.
    expect(find.byType(FilledButton), findsOneWidget);
  });
}

