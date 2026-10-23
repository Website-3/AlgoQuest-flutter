const fs = require('fs');
const p = 'C:/Users/ACER/Downloads/AlgoGuest/AlgoGuest/flutter_application_1/test/game_page_test.dart';
let c = fs.readFileSync(p, 'utf8');

const targetStr = `    // Dorong timer sampai semua perintah selesai dieksekusi.
    for (
      var i = 0;
      i < 400 && find.text('MONSTER DIKALAHKAN!').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.text('MONSTER DIKALAHKAN!'), findsOneWidget);

    // Lanjut -> soal logika asli muncul (dulu hanya placeholder).
    await tester.tap(find.text('Lanjut \\u25B8'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SOAL LOGIKA'), findsOneWidget);`;

const replacement = `    // Dorong timer sampai semua perintah selesai dieksekusi dan kuis muncul.
    for (
      var i = 0;
      i < 400 && find.text('Monster Dikalahkan!').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.text('Monster Dikalahkan!'), findsOneWidget);
    expect(find.text('Soal 1/5'), findsOneWidget);`;

c = c.replace(targetStr.replace(/\r\n/g, '\n'), replacement.replace(/\r\n/g, '\n'));
c = c.replace(targetStr.replace(/\n/g, '\r\n'), replacement.replace(/\n/g, '\r\n'));
fs.writeFileSync(p, c, 'utf8');
console.log('Fixed game_page_test.dart successfully');
