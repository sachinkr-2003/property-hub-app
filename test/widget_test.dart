import 'package:flutter_test/flutter_test.dart';
import 'package:property_hub_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PropertyHubApp());
    expect(find.byType(PropertyHubApp), findsOneWidget);
  });
}
