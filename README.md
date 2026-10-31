# Two-Detent iOS Action Sheet

一个完全基于 Flutter SDK、无第三方依赖的二段式底部面板 / iOS 风格 Action Sheet。

- 首段默认 **45%**，二段默认 **90%**，两档高度均可配置。
- 面板跟手拖动，松手按位置和速度吸附到最近一段。
- 面板内包含列表时：首段上滑优先展开面板；二段列表才滚动；列表回到顶部后继续下拉，手势交还给面板，面板跟手收回首段。
- 支持点击遮罩、取消按钮、下拉关闭。
- 附带地图风格的演示首页、长列表 sheet、Action Sheet 和实时高度滑杆。
- 全部基于 `showModalBottomSheet` + `DraggableScrollableSheet`，不依赖高德 SDK 或地图网络资源。

## 运行

环境：Flutter 3.44+ / Dart 3.12+。

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd two_detent_sheet_demo
flutter pub get
flutter run            # 选择 iOS 模拟器或 Android 设备
```

验证：

```bash
flutter analyze
flutter test
```

## 交互模型

| 场景 | 手势 | 结果 |
| --- | --- | --- |
| 首段，列表顶部 | 上滑 | 面板跟手变高，列表 offset 保持 0 |
| 首段 ↔ 二段 | 松手 | 按拖动距离/速度吸附到 45% 或 90% |
| 二段，列表内 | 上滑 | 面板保持 90%，列表滚动 |
| 二段，列表已滚动 | 下滑 | 列表回滚，面板保持 90% |
| 二段，列表回到顶部 | 继续下滑 | 列表停止滚动，面板开始跟手缩小 |
| 首段 | 快速下滑 | 关闭面板 |
| 首段 | 小幅慢速下拉 | 回弹到首段 |
| 任意状态 | 点击遮罩 / 取消 | 关闭，`Future` 返回 `null` |

## 快速使用

### iOS 风格 Action Sheet

```dart
final String? selected = await showTwoDetentActionSheet<String>(
  context: context,
  title: '分享到',
  message: '选择要执行的操作',
  initialDetent: 0.45,
  maxDetent: 0.90,
  actions: const <TwoDetentSheetAction<String>>[
    TwoDetentSheetAction(
      label: '复制链接',
      value: 'copy',
      icon: Icons.link_rounded,
    ),
    TwoDetentSheetAction(
      label: '删除',
      value: 'delete',
      icon: Icons.delete_outline_rounded,
      isDestructive: true,
    ),
  ],
);
```

- 取消按钮固定在底部，首段也始终可点。
- 点击操作项返回其 `value`；取消、遮罩、下拉关闭都返回 `null`。

### 自定义滚动的二段式面板

```dart
final String? selected = await showTwoDetentSheet<String>(
  context: context,
  initialDetent: 0.45,
  maxDetent: 0.90,
  builder: (BuildContext context, ScrollController scrollController) {
    return CustomScrollView(
      controller: scrollController, // 必须使用传入的 controller
      slivers: <Widget>[
        TwoDetentSheetHeaderSliver(
          title: '附近地点',
          subtitle: '18 个结果',
          backgroundColor: Colors.white,
        ),
        SliverList.builder(
          itemCount: places.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(places[index]),
              onTap: () => Navigator.of(context).pop(places[index]),
            );
          },
        ),
      ],
    );
  },
);
```

**关键约束**：内容必须把传入的 `ScrollController` 挂到唯一一个纵向滚动容器上。面板的手势联动依赖这个 controller；使用多个滚动容器或另建 controller 会失去滚动交接。

## API

### `showTwoDetentSheet<T>`

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `initialDetent` | `0.45` | 首段高度（屏幕可用高度的比例） |
| `maxDetent` | `0.90` | 二段高度 |
| `dismissible` | `true` | 是否允许遮罩/下拉关闭；关闭时首段为硬下限 |
| `backgroundColor` | 自动 | 面板背景色，自动适配亮暗色 |
| `barrierColor` | `0x66000000` | 遮罩颜色 |
| `useRootNavigator` | `false` | 是否使用根 Navigator |
| `routeSettings` | `null` | 路由参数 |
| `controller` | `null` | 可选的 `DraggableScrollableController` |

返回值：内容通过 `Navigator.pop(value)` 关闭时得到 `value`，其余关闭方式为 `null`。

### `showTwoDetentActionSheet<T>`

额外参数：`title`、`message`、`actions`、`cancelLabel`。`actions` 为 `List<TwoDetentSheetAction<T>>`，每项支持 `label`、`value`、`icon`、`isDestructive`。

### `TwoDetentSheetHeaderSliver`

放在内容 `CustomScrollView` 的 slivers 中，提供 pinned 的 grabber + 标题/副标题。因为它在滚动容器内部，拖动 grabber 也能展开/收起面板；pinned 保证二段滚动列表时标题不消失。

## 实现说明

- `DraggableScrollableSheet` 的滚动位置已经处理了“面板展开 ↔ 列表滚动”的 delta 交接，本项目的核心是把它和 iOS 外观、固定 header、固定取消按钮组合起来。
- `showModalBottomSheet(enableDrag: false)`：关闭路由自带拖拽，避免和内部 sheet 手势竞争；下拉关闭由 `shouldCloseOnMinExtent` 通知路由完成。
- `AlwaysScrollableScrollPhysics`：即使内容很短也接受拖动，否则短列表无法把面板拉起来。
- `ScrollConfiguration` 统一去掉滚动条 / Android glow，并使用 iOS 的 bounce 手感。
- 面板自动处理底部 Home Indicator 安全区。

## 目录

```
lib/
  main.dart
  two_detent_sheet.dart          # 公共 API
  src/
    two_detent_sheet.dart        # 低阶二段式面板
    two_detent_action_sheet.dart # iOS 风格 Action Sheet
    sheet_chrome.dart            # grabber header、配色、滚动行为
  demo/
    demo_home_page.dart          # 假地图 + 高度滑杆 + 入口
    map_backdrop.dart            # CustomPainter 地图底图
    demo_data.dart               # 附近地点数据
    nearby_places_content.dart   # 长列表演示 sheet
test/
  two_detent_sheet_test.dart
  two_detent_action_sheet_test.dart
  demo_smoke_test.dart
```

## 已知取舍

- 只支持两个 detent；更多段位需要扩展 `snapSizes` 和状态映射。
- 内容只支持一个协调滚动容器，不支持多层嵌套滚动。
- 吸附动画使用 `DraggableScrollableSheet` 内置实现；如果需要完全自定义的弹簧曲线，可以在后续替换成自定义 sheet。
- 演示使用绘制的地图占位，不接入真实地图 SDK。
