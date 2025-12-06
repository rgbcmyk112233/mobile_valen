import 'package:flutter_test/flutter_test.dart';
import 'package:nakamerch/main.dart';

void main() {
  testWidgets('App build smoke test', (WidgetTester tester) async {
    // Jalankan aplikasi
    await tester.pumpWidget(const MyApp());

    // Pastikan aplikasi berhasil muncul dan memuat SplashScreen
    expect(find.text('NAKAMERCH'), findsOneWidget);
  });
}
