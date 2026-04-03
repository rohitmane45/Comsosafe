import 'package:flutter_test/flutter_test.dart';

import 'package:cosmosafe/app.dart';

void main() {
  testWidgets('renders the CosmoSafe home screen', (tester) async {
    await tester.pumpWidget(const CosmosafeApp());

    expect(find.text('CosmoSafe'), findsOneWidget);
    expect(find.text('Start scan'), findsOneWidget);
  });
}
