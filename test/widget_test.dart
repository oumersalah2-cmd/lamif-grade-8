import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamif_grade_8/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LamifKutaa8App()));
    expect(find.byType(LamifKutaa8App), findsOneWidget);
  });
}
