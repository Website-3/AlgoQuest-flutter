import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/story_service.dart';
import 'package:flutter_application_1/widgets/npc_dialog.dart';

void main() {
  testWidgets('dialog cerita menampilkan NPC, judul, dan petunjuk', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final RegionStory s = StoryCatalog.story(0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    showNpcStory(ctx, region: 0, isEnglish: false),
                child: const Text('BUKA'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('BUKA'));
    await tester.pumpAndSettle();

    expect(find.text('Profesor Bit'), findsOneWidget);
    expect(find.text(s.title(false)), findsOneWidget);
    expect(find.text(s.hint(false)), findsOneWidget);
    expect(find.text(s.paragraphsId.first), findsOneWidget);

    // Tutup.
    await tester.tap(find.text('Mengerti!'));
    await tester.pumpAndSettle();
    expect(find.text('Profesor Bit'), findsNothing);
  });

  testWidgets('dialog cerita bahasa Inggris', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final RegionStory s = StoryCatalog.story(4);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showNpcStory(ctx, region: 4, isEnglish: true),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(find.text('Professor Bit'), findsOneWidget);
    expect(find.text(s.titleEn), findsOneWidget);
    expect(find.text('Got it!'), findsOneWidget);
  });
}
