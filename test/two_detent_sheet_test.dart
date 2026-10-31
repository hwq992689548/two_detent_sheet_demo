import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_detent_sheet_demo/two_detent_sheet.dart';

const Key _sheetContentKey = Key('sheet-content');

void main() {
  testWidgets('opens at the default first detent and expands to max', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);
    ScrollController? controller;

    await tester.pumpWidget(
      _SheetHarness(
        builder: (BuildContext context, ScrollController scrollController) {
          controller = scrollController;
          return _buildList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final Finder content = find.byKey(_sheetContentKey);
    expect(content, findsOneWidget);
    expect(tester.getRect(content).top, closeTo(844 * 0.55, 2));

    final TestGesture gesture = await tester.startGesture(
      tester.getRect(content).center,
    );
    await gesture.moveBy(const Offset(0, -120));
    await tester.pump();
    final double trackedTop = tester.getRect(content).top;
    expect(trackedTop, lessThan(844 * 0.55));
    expect(trackedTop, greaterThan(844 * 0.10));

    await gesture.moveBy(const Offset(0, -320));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.getRect(content).top, closeTo(844 * 0.10, 2));
    expect(controller?.offset, 0);
  });

  testWidgets('long list scrolls at max and hands the drag back to the sheet', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);
    late ScrollController controller;

    await tester.pumpWidget(
      _SheetHarness(
        builder: (BuildContext context, ScrollController scrollController) {
          controller = scrollController;
          return _buildList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final Finder content = find.byKey(_sheetContentKey);

    // Track the finger while the sheet itself is expanding: the list must stay
    // pinned at offset zero.
    TestGesture gesture = await tester.startGesture(
      tester.getRect(content).center,
    );
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(controller.offset, 0);
    expect(tester.getRect(content).top, lessThan(844 * 0.55));
    await gesture.up();
    await tester.pumpAndSettle();

    // Expand fully, then scroll the list while the sheet stays at 90%.
    await tester.timedDrag(
      content,
      const Offset(0, -420),
      const Duration(milliseconds: 700),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(content).top, closeTo(844 * 0.10, 2));

    await tester.timedDrag(
      content,
      const Offset(0, -200),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(content).top, closeTo(844 * 0.10, 2));
    expect(controller.offset, greaterThan(0));

    // Set up a known scroll offset, then drag down: the list consumes the
    // first part of the drag while the sheet remains at max.
    controller.jumpTo(200);
    await tester.pump();
    gesture = await tester.startGesture(tester.getRect(content).center);
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump();
    expect(tester.getRect(content).top, closeTo(844 * 0.10, 2));
    expect(controller.offset, closeTo(50, 1));

    // The list is at the top; the rest of the same drag starts moving the
    // sheet down. Move in small steps, like real pointer events.
    for (int i = 0; i < 60; i++) {
      await gesture.moveBy(const Offset(0, 5));
      await tester.pump();
    }
    expect(controller.offset, lessThanOrEqualTo(5));
    expect(tester.getRect(content).top, greaterThan(844 * 0.15));
    expect(tester.getRect(content).top, lessThan(844 * 0.55));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    expect(tester.getRect(content).top, closeTo(844 * 0.55, 2));
  });

  testWidgets('dismissible sheet closes on a downward drag', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);

    await tester.pumpWidget(
      _SheetHarness(
        builder: (BuildContext context, ScrollController scrollController) {
          return _buildList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.timedDrag(
      find.byKey(_sheetContentKey),
      const Offset(0, 320),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(_sheetContentKey), findsNothing);
  });

  testWidgets('dismissible false keeps the sheet at the first detent', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);

    await tester.pumpWidget(
      _SheetHarness(
        dismissible: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return _buildList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final Finder content = find.byKey(_sheetContentKey);
    await tester.timedDrag(
      content,
      const Offset(0, 320),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();

    expect(tester.getRect(content).top, closeTo(844 * 0.55, 2));
  });

  testWidgets('short content can still be dragged', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);

    await tester.pumpWidget(
      _SheetHarness(
        builder: (BuildContext context, ScrollController scrollController) {
          return ListView(
            key: _sheetContentKey,
            controller: scrollController,
            children: const <Widget>[
              SizedBox(height: 80, child: Center(child: Text('only item'))),
            ],
          );
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final Finder content = find.byKey(_sheetContentKey);
    await tester.timedDrag(
      content,
      const Offset(0, -400),
      const Duration(milliseconds: 700),
    );
    await tester.pumpAndSettle();

    expect(tester.getRect(content).top, closeTo(844 * 0.10, 2));
  });

  testWidgets('honors custom detents', (WidgetTester tester) async {
    _setUpPhone(tester);

    await tester.pumpWidget(
      _SheetHarness(
        initialDetent: 0.5,
        maxDetent: 0.85,
        builder: (BuildContext context, ScrollController scrollController) {
          return _buildList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final Finder content = find.byKey(_sheetContentKey);
    expect(tester.getRect(content).top, closeTo(844 * 0.50, 2));

    await tester.timedDrag(
      content,
      const Offset(0, -500),
      const Duration(milliseconds: 700),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(content).top, closeTo(844 * 0.15, 2));
  });

  testWidgets('dragging the pinned header expands the sheet', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);

    await tester.pumpWidget(
      _SheetHarness(
        builder: (BuildContext context, ScrollController scrollController) {
          return _buildHeaderedList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final Finder content = find.byKey(_sheetContentKey);
    expect(tester.getRect(content).top, closeTo(844 * 0.55, 2));
    expect(find.text('附近地点'), findsOneWidget);

    await tester.timedDrag(
      find.text('附近地点'),
      const Offset(0, -420),
      const Duration(milliseconds: 700),
    );
    await tester.pumpAndSettle();

    expect(tester.getRect(content).top, closeTo(844 * 0.10, 2));
    expect(find.text('附近地点'), findsOneWidget);
  });

  testWidgets('non-dismissible sheet ignores scrim taps', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);

    await tester.pumpWidget(
      _SheetHarness(
        dismissible: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return _buildList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(_sheetContentKey), findsOneWidget);
  });

  testWidgets('header and rows survive a large text scale', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _SheetHarness(
        builder: (BuildContext context, ScrollController scrollController) {
          return _buildHeaderedList(scrollController);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('附近地点'), findsOneWidget);

    await tester.timedDrag(
      find.text('附近地点'),
      const Offset(0, -420),
      const Duration(milliseconds: 700),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('rejects invalid detents', () {
    expect(
      () => showTwoDetentSheet<void>(
        context: _FakeContext(),
        builder: (BuildContext context, ScrollController controller) {
          return const SizedBox.shrink();
        },
        initialDetent: 0.9,
        maxDetent: 0.8,
      ),
      throwsArgumentError,
    );
  });
}

void _setUpPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildHeaderedList(ScrollController controller) {
  return CustomScrollView(
    key: _sheetContentKey,
    controller: controller,
    slivers: <Widget>[
      const TwoDetentSheetHeaderSliver(title: '附近地点', subtitle: '18 个结果'),
      SliverList.builder(
        itemCount: 40,
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(height: 56, child: Center(child: Text('row $index')));
        },
      ),
    ],
  );
}

Widget _buildList(ScrollController controller) {
  return ListView.builder(
    key: _sheetContentKey,
    controller: controller,
    itemCount: 40,
    itemBuilder: (BuildContext context, int index) {
      return SizedBox(height: 56, child: Center(child: Text('row $index')));
    },
  );
}

class _SheetHarness extends StatelessWidget {
  const _SheetHarness({
    required this.builder,
    this.dismissible = true,
    this.initialDetent = 0.45,
    this.maxDetent = 0.9,
  });

  final TwoDetentSheetContentBuilder builder;
  final bool dismissible;
  final double initialDetent;
  final double maxDetent;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  showTwoDetentSheet<String>(
                    context: context,
                    dismissible: dismissible,
                    initialDetent: initialDetent,
                    maxDetent: maxDetent,
                    builder: builder,
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FakeContext extends Fake implements BuildContext {}
