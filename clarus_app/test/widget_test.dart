import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clarus_app/main.dart';

void main() {
  testWidgets('App launches and shows Clarus title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ClarusApp());
    expect(find.text('Clarus'), findsOneWidget);
  });
}
