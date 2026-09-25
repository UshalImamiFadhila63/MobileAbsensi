import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:absensi_app/main.dart';

void main() {
  testWidgets('Absensi app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AbsensiApp());

    expect(find.text('Absensi App'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
