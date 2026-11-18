// Widget smoke test — updated for DallolBookApp which now requires a
// pre-initialised LanguageProvider passed as `lang`.
import 'package:flutter_test/flutter_test.dart';
import 'package:booking_multipurpose_platform/providers/language_provider.dart';
import 'package:booking_multipurpose_platform/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final lang = LanguageProvider();
    await tester.pumpWidget(DallolBookApp(lang: lang));
    expect(find.byType(DallolBookApp), findsOneWidget);
  });
}
