import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Colors and measurements shared by the sheet chrome and content widgets.
const Color kTwoDetentLightSurface = Color(0xFFFFFFFF);
const Color kTwoDetentDarkSurface = Color(0xFF1C1C1E);
const Color kTwoDetentAccent = Color(0xFF007AFF);
const Color kTwoDetentDestructive = Color(0xFFFF3B30);
const Color kTwoDetentSecondaryLight = Color(0xFF8E8E93);
const Color kTwoDetentSecondaryDark = Color(0xFF98989F);
const double kTwoDetentCornerRadius = 20;

/// Resolves the sheet surface, honoring an explicit override.
Color twoDetentSheetSurface(BuildContext context, [Color? override]) {
  if (override != null) {
    return override;
  }
  return Theme.of(context).brightness == Brightness.dark
      ? kTwoDetentDarkSurface
      : kTwoDetentLightSurface;
}

Color twoDetentDivider(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0x33FFFFFF)
      : const Color(0xFFE5E5EA);
}

Color twoDetentSecondaryText(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? kTwoDetentSecondaryDark
      : kTwoDetentSecondaryLight;
}

/// A pinned grabber + optional title/subtitle for a scrollable sheet body.
///
/// The header must live inside the sheet's [CustomScrollView]. Being part of
/// the scroll view means dragging it also drives the sheet extent, while
/// pinning keeps it visible when the inner list scrolls at the expanded detent.
class TwoDetentSheetHeaderSliver extends StatelessWidget {
  const TwoDetentSheetHeaderSliver({
    super.key,
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.showHandle = true,
    this.showDivider = true,
  });

  final String? title;
  final String? subtitle;

  /// Overrides the sheet surface. When null, the surface follows the current
  /// theme, matching the default used by `showTwoDetentSheet`.
  final Color? backgroundColor;
  final bool showHandle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = backgroundColor ?? twoDetentSheetSurface(context);
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color secondaryColor = twoDetentSecondaryText(context);
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    // Keep the pinned header tall enough for the current text scale instead of
    // hard-coding a height that overflows with accessibility font sizes.
    double height = 16;
    if (showHandle) {
      height += 15; // 5px handle + 10px gap.
    }
    if (title != null) {
      height += scaler.scale(17) * 1.25;
    }
    if (subtitle != null) {
      height += scaler.scale(13) * 1.3 + 2;
    }

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(
        height: height,
        backgroundColor: surface,
        dividerColor: twoDetentDivider(context),
        showDivider: showDivider,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (showHandle) ...<Widget>[
              Semantics(
                label: '拖动调整面板高度',
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x66FFFFFF)
                        : const Color(0xFFC7C7CC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (title != null)
              Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  letterSpacing: -0.2,
                ),
              ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryColor,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required this.height,
    required this.backgroundColor,
    required this.dividerColor,
    required this.showDivider,
    required this.child,
  });

  final double height;
  final Color backgroundColor;
  final Color dividerColor;
  final bool showDivider;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showDivider
            ? Border(bottom: BorderSide(color: dividerColor, width: 0.5))
            : null,
      ),
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dividerColor != dividerColor ||
        oldDelegate.showDivider != showDivider ||
        oldDelegate.child != child;
  }
}

/// iOS-like scrolling for sheet content.
///
/// [AlwaysScrollableScrollPhysics] is essential: short content must still
/// accept a vertical drag so [DraggableScrollableSheet] can expand the sheet.
class TwoDetentSheetScrollBehavior extends MaterialScrollBehavior {
  const TwoDetentSheetScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}
