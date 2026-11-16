import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pemutar_musik_offline/main.dart';

void main() {
  testWidgets('Music player UI and interaction smoke test', (
    WidgetTester tester,
  ) async {
    // Berikan parameter isLoggedIn dan initialUserName sesuai konstruktor terbaru
    await tester.pumpWidget(
      const MusicPlayerApp(isLoggedIn: true, initialUserName: 'Tester'),
    );

    // 1. Verifikasi sapaan nama user di AppBar muncul
    expect(find.text('Halo, Tester'), findsOneWidget);

    // 2. Verifikasi daftar lagu tampil (Lagu Populer 1 muncul di list & mini player)
    expect(find.text('Lagu Populer 1'), findsNWidgets(2));
    expect(find.text('Lagu Favorit 2'), findsOneWidget);

    // 3. Verifikasi tombol play awalnya berikon play_arrow
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsNothing);

    // 4. Klik tombol play dan pastikan berubah menjadi ikon pause
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });
}
