import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbe/main.dart';

void main() {
  testWidgets('unauthenticated users land on the login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OrbeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Entrar na sua conta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
