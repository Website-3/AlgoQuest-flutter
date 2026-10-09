import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/adventure_page.dart';
import 'package:flutter_application_1/widgets/hero_token.dart';
import 'package:flutter_application_1/widgets/minimap.dart';
import 'package:flutter_application_1/widgets/virtual_joystick.dart';

Widget _wrap() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: AdventurePage(
        region: 0,
        level: 0,
        isEnglish: false,
        onLanguageChanged: () {},
        onBack: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('menampilkan elemen utama halaman petualangan',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AdventurePage), findsOneWidget);
    expect(find.byType(VirtualJoystick), findsOneWidget);
    expect(find.byType(HeroToken), findsOneWidget);
    expect(find.byType(Minimap), findsOneWidget);
    expect(find.textContaining('WILAYAH 1'), findsOneWidget);
    expect(find.text('Joystick / WASD untuk jelajah'), findsOneWidget);

    // Tidak boleh ada overflow.
    expect(tester.takeException(), isNull);
  });

  testWidgets('karakter bergerak saat tombol panah ditekan',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 50));

    final Offset before = tester.getTopLeft(find.byType(HeroToken));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    final Offset after = tester.getTopLeft(find.byType(HeroToken));
    expect(after.dx, greaterThan(before.dx));
  });

  testWidgets('karakter bergerak saat joystick digeser',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 50));

    final Offset before = tester.getTopLeft(find.byType(HeroToken));

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(VirtualJoystick)) + const Offset(24, 0),
    );
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pump();

    final Offset after = tester.getTopLeft(find.byType(HeroToken));
    expect(after.dx, greaterThan(before.dx));
  });
}