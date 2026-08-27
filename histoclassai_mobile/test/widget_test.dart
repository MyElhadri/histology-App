import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:histoclassai_mobile/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HistoClassApp());

    // Verify the app renders the login screen welcome text
    expect(find.text('Bon retour !'), findsOneWidget);
  });
}
