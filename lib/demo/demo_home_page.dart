import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../two_detent_sheet.dart';
import 'map_backdrop.dart';
import 'nearby_places_content.dart';

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  static const Color _accent = Color(0xFF007AFF);
  static const Color _surface = Color(0xFFFFFFFF);

  static const List<TwoDetentSheetAction<String>> _actions =
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
          label: '添加到收藏',
          value: 'favorite',
          icon: Icons.bookmark_border_rounded,
        ),
        TwoDetentSheetAction<String>(
          label: '分享给朋友',
          value: 'share',
          icon: Icons.ios_share_rounded,
        ),
        TwoDetentSheetAction<String>(
          label: '编辑',
          value: 'edit',
          icon: Icons.edit_outlined,
        ),
        TwoDetentSheetAction<String>(
          label: '移动到文件夹',
          value: 'move',
          icon: Icons.folder_outlined,
        ),
        TwoDetentSheetAction<String>(
          label: '隐藏',
          value: 'hide',
          icon: Icons.visibility_off_outlined,
        ),
        TwoDetentSheetAction<String>(
          label: '删除',
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
        ),
      ];

  double _initialDetent = 0.45;
  double _maxDetent = 0.90;
  String? _lastSelection;

  Future<void> _openNearby() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String? selected = await showTwoDetentSheet<String>(
      context: context,
      initialDetent: _initialDetent,
      maxDetent: _maxDetent,
      backgroundColor: _surface,
      builder: (BuildContext context, ScrollController scrollController) {
        return NearbyPlacesContent(
          scrollController: scrollController,
          surfaceColor: _surface,
        );
      },
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() => _lastSelection = '已选择：$selected');
  }

  Future<void> _openActions() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String? selected = await showTwoDetentActionSheet<String>(
      context: context,
      title: '分享到',
      message: '选择要执行的操作',
      initialDetent: _initialDetent,
      maxDetent: _maxDetent,
      backgroundColor: _surface,
      actions: _actions,
    );
    if (!mounted || selected == null) {
      return;
    }
    final String label = _actions.firstWhere((
      TwoDetentSheetAction<String> action,
    ) {
      return action.value == selected;
    }).label;
    setState(() => _lastSelection = '已选择：$label');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0EEE8),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const MapBackdrop(),
            const Align(
              alignment: Alignment(-0.55, -0.35),
              child: IgnorePointer(
                child: _MapPin(
                  icon: Icons.local_cafe_outlined,
                  color: Color(0xFFB07A45),
                  label: '云朵咖啡',
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0.56, -0.48),
              child: IgnorePointer(
                child: _MapPin(
                  icon: Icons.park_outlined,
                  color: Color(0xFF4C9A5F),
                  label: '人民公园',
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0.42, -0.05),
              child: IgnorePointer(
                child: _MapPin(
                  icon: Icons.directions_subway_outlined,
                  color: Color(0xFF3A7BD5),
                  label: '静安寺站',
                ),
              ),
            ),
            const Align(
              alignment: Alignment(-0.12, 0.02),
              child: IgnorePointer(child: _CurrentLocationDot()),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _SearchBar(accent: _accent),
                    const SizedBox(height: 12),
                    const _LocationChip(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: _buildControlCard(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '二段式 Action Sheet',
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '首段固定，上滑展开；列表到顶后下拉收回',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'iOS 风格',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetentSlider(
            label: '首段高度',
            value: _initialDetent,
            min: 0.30,
            max: 0.60,
            divisions: 6,
            accent: _accent,
            onChanged: (double value) {
              setState(() => _initialDetent = value);
            },
          ),
          _DetentSlider(
            label: '展开高度',
            value: _maxDetent,
            min: 0.70,
            max: 0.95,
            divisions: 5,
            accent: _accent,
            onChanged: (double value) {
              setState(() => _maxDetent = value);
            },
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: _SheetDemoButton(
                  label: '附近地点',
                  icon: Icons.place_outlined,
                  filled: true,
                  accent: _accent,
                  onTap: _openNearby,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetDemoButton(
                  label: '分享菜单',
                  icon: Icons.ios_share_rounded,
                  filled: false,
                  accent: _accent,
                  onTap: _openActions,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ResultBanner(text: _lastSelection, accent: _accent),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF8E8E93)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '搜索地点、公交、美食',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
                letterSpacing: -0.1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '附近',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF34C759),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '静安寺 · 附近 2 km',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3C3C43),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C3C43),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.65, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(scale: value, child: child);
      },
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetentSlider extends StatelessWidget {
  const _DetentSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.accent,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color accent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3C3C43),
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 32,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: accent,
              inactiveTrackColor: const Color(0xFFE5E5EA),
              thumbColor: Colors.white,
              overlayColor: accent.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
                elevation: 2,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: '${(value * 100).round()}%',
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetDemoButton extends StatelessWidget {
  const _SheetDemoButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(Size.fromHeight(46)),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 12),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      backgroundColor: filled
          ? WidgetStatePropertyAll<Color>(accent)
          : WidgetStatePropertyAll<Color>(accent.withValues(alpha: 0.08)),
      foregroundColor: WidgetStatePropertyAll<Color>(
        filled ? Colors.white : accent,
      ),
      overlayColor: WidgetStatePropertyAll<Color>(
        (filled ? Colors.white : accent).withValues(alpha: 0.12),
      ),
      textStyle: const WidgetStatePropertyAll<TextStyle>(
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(
          color: filled ? Colors.transparent : accent.withValues(alpha: 0.18),
        ),
      ),
    );

    return FilledButton.icon(
      style: style,
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.text, required this.accent});

  final String? text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: child,
            ),
          );
        },
        child: Row(
          key: ValueKey<String?>(text),
          children: <Widget>[
            Icon(
              text == null ? Icons.gesture_rounded : Icons.check_circle_rounded,
              size: 16,
              color: text == null ? const Color(0xFF8E8E93) : accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text ?? '选择结果会显示在这里',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: text == null
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFF3C3C43),
                  fontWeight: text == null ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
