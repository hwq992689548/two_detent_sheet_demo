import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_detent_sheet_demo/main.dart';

void main() {
  testWidgets('demo renders and returns a nearby place', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TwoDetentSheetDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('二段式 Action Sheet'), findsOneWidget);
    expect(find.text('附近地点'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('附近地点'));
    await tester.pumpAndSettle();

    expect(find.text('云朵咖啡'), findsWidgets);
    await tester.tap(find.text('云朵咖啡').last);
    await tester.pumpAndSettle();

    expect(find.text('已选择：云朵咖啡'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('demo fits a compact phone without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TwoDetentSheetDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('二段式 Action Sheet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('demo opens the action sheet and returns an action', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TwoDetentSheetDemoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('分享菜单'));
    await tester.pumpAndSettle();

    expect(find.text('分享到'), findsOneWidget);
    expect(find.text('取消').hitTestable(), findsOneWidget);

    await tester.tap(find.text('复制链接'));
    await tester.pumpAndSettle();

    expect(find.text('已选择：复制链接'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
