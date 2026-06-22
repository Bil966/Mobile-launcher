import 'package:flutter_test/flutter_test.dart';
import 'package:geode_mod_manager/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GeodeModManagerApp());
    expect(find.text('Geode Mod Manager'), findsOneWidget);
  });
}
