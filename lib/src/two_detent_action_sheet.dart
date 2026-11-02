import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sheet_chrome.dart';
import 'two_detent_sheet.dart';

/// A single row in a two-detent action sheet.
class TwoDetentSheetAction<T> {
  const TwoDetentSheetAction({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
  });

  /// Visible label of the row.
  final String label;

  /// Value returned by [showTwoDetentActionSheet] when this row is tapped.
  final T value;

  /// Optional leading icon.
  final IconData? icon;

  /// Paints the row in the system destructive color.
  final bool isDestructive;
}

/// Shows an iOS style action sheet with two detents and a pinned cancel row.
///
/// The sheet opens at [initialDetent] and expands to [maxDetent] with the same
/// gesture/scroll handoff as [showTwoDetentSheet]. The cancel row stays pinned
/// at the bottom so it is reachable at both detents.
///
/// Returns the tapped action's [TwoDetentSheetAction.value], or `null` when the
/// sheet is cancelled/dismissed.
Future<T?> showTwoDetentActionSheet<T>({
  required BuildContext context,
  String? title,
  String? message,
  required List<TwoDetentSheetAction<T>> actions,
  String cancelLabel = '取消',
  double initialDetent = 0.45,
  double maxDetent = 0.9,
  bool dismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  final ThemeData theme = Theme.of(context);
  final Color surfaceColor = backgroundColor ?? twoDetentSheetSurface(context);

  return showTwoDetentSheet<T>(
    context: context,
    initialDetent: initialDetent,
    maxDetent: maxDetent,
    dismissible: dismissible,
    backgroundColor: surfaceColor,
    barrierColor:
        barrierColor ??
        (theme.brightness == Brightness.dark
            ? const Color(0x99000000)
            : const Color(0x66000000)),
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (BuildContext context, ScrollController scrollController) {
      return _ActionSheetContent<T>(
        scrollController: scrollController,
        surfaceColor: surfaceColor,
        title: title,
        message: message,
        actions: actions,
        cancelLabel: cancelLabel,
      );
    },
  );
}

class _ActionSheetContent<T> extends StatelessWidget {
  const _ActionSheetContent({
    required this.scrollController,
    required this.surfaceColor,
    required this.title,
    required this.message,
    required this.actions,
    required this.cancelLabel,
  });

  final ScrollController scrollController;
  final Color surfaceColor;
  final String? title;
  final String? message;
  final List<TwoDetentSheetAction<T>> actions;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = twoDetentDivider(context);
    final Color secondaryColor = twoDetentSecondaryText(context);
    final bool hasLeading = actions.any(
      (TwoDetentSheetAction<T> action) => action.icon != null,
    );
    final double footerHeight = _footerHeight(context);

    final List<Widget> contentSlivers = <Widget>[
      TwoDetentSheetHeaderSliver(
        title: title,
        backgroundColor: surfaceColor,
        showDivider: message != null,
      ),
      if (message != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: secondaryColor,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      SliverList.separated(
        itemCount: actions.length,
        itemBuilder: (BuildContext context, int index) {
          return _ActionRow<T>(action: actions[index], hasLeading: hasLeading);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 0.5,
            thickness: 0.5,
            color: dividerColor,
            indent: hasLeading ? 60 : 20,
          );
        },
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // The modal route animates the sheet from zero height, and callers can
        // configure a very small first detent. A pinned footer cannot fit in
        // those cases, so fall back to a single scrollable that includes the
        // cancel row instead of overflowing the Column.
        final bool tooShort =
            constraints.maxHeight.isFinite &&
            constraints.maxHeight <= footerHeight;

        if (tooShort) {
          return CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              ...contentSlivers,
              SliverToBoxAdapter(
                child: _CancelFooter(
                  label: cancelLabel,
                  surfaceColor: surfaceColor,
                  dividerColor: dividerColor,
                ),
              ),
            ],
          );
        }

        return Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                slivers: contentSlivers,
              ),
            ),
            _CancelFooter(
              label: cancelLabel,
              surfaceColor: surfaceColor,
              dividerColor: dividerColor,
            ),
          ],
        );
      },
    );
  }

  double _footerHeight(BuildContext context) {
    final double textHeight = MediaQuery.textScalerOf(context).scale(17) * 1.25;
    return math.max(56.0, textHeight + 24.0) + 0.5;
  }
}

class _ActionRow<T> extends StatelessWidget {
  const _ActionRow({required this.action, required this.hasLeading});

  final TwoDetentSheetAction<T> action;
  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    final Color color = action.isDestructive
        ? kTwoDetentDestructive
        : Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1C1C1E);
    final Color iconColor = action.isDestructive
        ? kTwoDetentDestructive
        : Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A84FF)
        : kTwoDetentAccent;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick().ignore();
        Navigator.of(context).pop<T>(action.value);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: <Widget>[
              if (hasLeading) ...<Widget>[
                SizedBox(
                  width: 22,
                  height: 22,
                  child: action.icon == null
                      ? null
                      : Icon(action.icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.2,
                    color: color,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelFooter extends StatelessWidget {
  const _CancelFooter({
    required this.label,
    required this.surfaceColor,
    required this.dividerColor,
  });

  final String label;
  final Color surfaceColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A84FF)
        : kTwoDetentAccent;

    return Material(
      color: surfaceColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(height: 0.5, thickness: 0.5, color: dividerColor),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick().ignore();
              Navigator.of(context).pop();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: accent,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
