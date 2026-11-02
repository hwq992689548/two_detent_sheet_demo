import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_detent_sheet_demo/two_detent_sheet.dart';

const List<TwoDetentSheetAction<String>> _actions =
    <TwoDetentSheetAction<String>>[
      TwoDetentSheetAction<String>(
        label: '复制链接',
        value: 'copy',
        icon: Icons.link_rounded,
      ),
      TwoDetentSheetAction<String>(
        label: '保存图片',
        value: 'save',
        icon: Icons.download_rounded,
      ),
      TwoDetentSheetAction<String>(
        label: '分享给朋友',
        value: 'share',
        icon: Icons.ios_share_rounded,
      ),
      TwoDetentSheetAction<String>(
        label: '删除',
        value: 'delete',
        icon: Icons.delete_outline_rounded,
        isDestructive: true,
      ),
    ];

void main() {
  testWidgets('returns the tapped action value', (WidgetTester tester) async {
    _setUpPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: _ActionHarness()));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('分享到'), findsOneWidget);
    expect(find.text('复制链接'), findsOneWidget);
    expect(find.text('取消').hitTestable(), findsOneWidget);

    await tester.tap(find.text('复制链接'));
    await tester.pumpAndSettle();

    expect(find.text('result: copy'), findsOneWidget);
  });

  testWidgets('cancel is pinned and returns null', (WidgetTester tester) async {
    _setUpPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: _ActionHarness()));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final Finder cancel = find.text('取消');
    expect(cancel.hitTestable(), findsOneWidget);
    expect(
      tester.getRect(cancel).bottom,
      lessThanOrEqualTo(tester.view.physicalSize.height + 0.1),
    );

    await tester.tap(cancel);
    await tester.pumpAndSettle();

    expect(find.text('result: null'), findsOneWidget);
  });

  testWidgets('tapping the scrim dismisses with null', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: _ActionHarness()));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('result: null'), findsOneWidget);
  });

  testWidgets('very small first detent does not overflow', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);
    await tester.pumpWidget(
      const MaterialApp(home: _ActionHarness(initialDetent: 0.05)),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('handles large text on a compact phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: _ActionHarness()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('取消').hitTestable(), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('result: null'), findsOneWidget);
  });

  testWidgets('long action list scrolls at the expanded detent', (
    WidgetTester tester,
  ) async {
    _setUpPhone(tester);
    await tester.pumpWidget(
      const MaterialApp(home: _ActionHarness(actionCount: 14)),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('操作 1'), findsOneWidget);
    expect(find.text('操作 14'), findsNothing);

    await tester.timedDrag(
      find.text('操作 1'),
      const Offset(0, -500),
      const Duration(milliseconds: 800),
    );
    await tester.pumpAndSettle();

    expect(find.text('操作 14'), findsOneWidget);
    expect(find.text('取消').hitTestable(), findsOneWidget);
  });
}

void _setUpPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _ActionHarness extends StatefulWidget {
  const _ActionHarness({this.actionCount = 4, this.initialDetent = 0.45});

  final int actionCount;
  final double initialDetent;

  @override
  State<_ActionHarness> createState() => _ActionHarnessState();
}

class _ActionHarnessState extends State<_ActionHarness> {
  String _result = 'none';

  List<TwoDetentSheetAction<String>> get _sheetActions {
    if (widget.actionCount == _actions.length) {
      return _actions;
    }
    return List<TwoDetentSheetAction<String>>.generate(
      widget.actionCount,
      (int index) => TwoDetentSheetAction<String>(
        label: '操作 ${index + 1}',
        value: 'action-$index',
        icon: Icons.circle_outlined,
      ),
    );
  }

  Future<void> _open() async {
    final String? selected = await showTwoDetentActionSheet<String>(
      context: context,
      title: '分享到',
      message: '选择要执行的操作',
      initialDetent: widget.initialDetent,
      actions: _sheetActions,
      backgroundColor: Colors.white,
    );
    if (!mounted) {
      return;
    }
    setState(() => _result = selected ?? 'null');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(onPressed: _open, child: const Text('open')),
            const SizedBox(height: 8),
            Text('result: $_result'),
          ],
        ),
      ),
    );
  }
}
