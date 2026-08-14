import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocerylist/presentation/widgets/ad_banner.dart';

void main() {
  testWidgets('VERIFY: FloatingActionButton (+ Add Item) does not overlap with AdBanner', (WidgetTester tester) async {
    // Build the Scaffold with AdBanner at the bottom of Column and FloatingActionButton with bottom 60 padding
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [
              Expanded(child: SizedBox()),
              AdBanner(),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: FloatingActionButton.extended(
              onPressed: null,
              label: const Text('Add Item'),
              icon: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find FloatingActionButton and AdBanner widgets
    final fabFinder = find.byType(FloatingActionButton);
    final adBannerFinder = find.byType(AdBanner);

    expect(fabFinder, findsOneWidget);
    expect(adBannerFinder, findsOneWidget);

    // Get render bounding boxes
    final Rect fabRect = tester.getRect(fabFinder);
    final Rect adBannerRect = tester.getRect(adBannerFinder);

    debugPrint('📍 FAB Bounding Box: $fabRect');
    debugPrint('📍 AdBanner Bounding Box: $adBannerRect');

    // 1. Verify NO geometrical overlap/intersection between FAB and AdBanner
    final bool overlaps = fabRect.overlaps(adBannerRect);
    expect(overlaps, isFalse, reason: 'FloatingActionButton overlaps with AdBanner! AdMob policy violation.');

    // 2. Verify FAB bottom is strictly higher than (or equal to) AdBanner top edge
    expect(
      fabRect.bottom <= adBannerRect.top,
      isTrue,
      reason: 'FloatingActionButton bottom (${fabRect.bottom}) must be at or above AdBanner top (${adBannerRect.top})',
    );
  });

  testWidgets('VERIFY: Top and Bottom AdBanner coexist without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [
              AdBanner(customAdUnitId: 'test_top_ad_unit'),
              Expanded(child: Center(child: Text('Content'))),
              AdBanner(customAdUnitId: 'test_bottom_ad_unit'),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bannerFinders = find.byType(AdBanner);
    expect(bannerFinders, findsNWidgets(2));
    expect(find.text('Content'), findsOneWidget);
  });
}
