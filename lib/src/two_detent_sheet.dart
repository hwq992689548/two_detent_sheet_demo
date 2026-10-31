import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sheet_chrome.dart';

/// Builds the scrollable content of a two-detent sheet.
///
/// The [scrollController] must be attached to the content's scrollable (for
/// example `ListView(controller: scrollController)` or
/// `CustomScrollView(controller: scrollController)`). Without that controller
/// the sheet cannot coordinate its extent with the content's scroll position.
typedef TwoDetentSheetContentBuilder =
    Widget Function(BuildContext context, ScrollController scrollController);

/// Shows an iOS style bottom sheet with two detents.
///
/// The sheet opens at [initialDetent] (a fraction of the available height) and
/// can be expanded to [maxDetent]. Dragging up from the first detent moves the
/// sheet first; the content only scrolls once the sheet has reached
/// [maxDetent]. Dragging down scrolls the content back to its top and then
/// hands the gesture back to the sheet, which follows the finger down.
///
/// When [dismissible] is true the sheet can also be dismissed by dragging it
/// below the first detent or by tapping the scrim. Popping the sheet returns
/// `null`.
///
/// The content is responsible for its own header/cancel UI. See
/// [TwoDetentSheetHeaderSliver] for a grabber header that stays pinned while
/// the content scrolls.
Future<T?> showTwoDetentSheet<T>({
  required BuildContext context,
  required TwoDetentSheetContentBuilder builder,
  double initialDetent = 0.45,
  double maxDetent = 0.9,
  bool dismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
  DraggableScrollableController? controller,
}) {
  _validateDetents(initialDetent, maxDetent);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ?? const Color(0x66000000),
    elevation: 0,
    isDismissible: dismissible,
    // The route-level drag would compete with DraggableScrollableSheet's own
    // gesture handling. The sheet is dismissed through shouldCloseOnMinExtent
    // instead.
    enableDrag: false,
    useSafeArea: false,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    shape: const RoundedRectangleBorder(),
    clipBehavior: Clip.none,
    builder: (BuildContext sheetContext) {
      final Color surfaceColor = twoDetentSheetSurface(
        sheetContext,
        backgroundColor,
      );
      return _TwoDetentSheetBody(
        builder: builder,
        initialDetent: initialDetent,
        maxDetent: maxDetent,
        dismissible: dismissible,
        surfaceColor: surfaceColor,
        controller: controller,
      );
    },
  );
}

void _validateDetents(double initialDetent, double maxDetent) {
  if (!initialDetent.isFinite || initialDetent <= 0 || initialDetent >= 1) {
    throw ArgumentError.value(
      initialDetent,
      'initialDetent',
      'must be greater than 0 and less than 1',
    );
  }
  if (!maxDetent.isFinite || maxDetent <= 0 || maxDetent > 1) {
    throw ArgumentError.value(
      maxDetent,
      'maxDetent',
      'must be greater than 0 and less than or equal to 1',
    );
  }
  if (initialDetent >= maxDetent) {
    throw ArgumentError.value(
      initialDetent,
      'initialDetent',
      'must be smaller than maxDetent ($maxDetent)',
    );
  }
}

class _TwoDetentSheetBody extends StatelessWidget {
  const _TwoDetentSheetBody({
    required this.builder,
    required this.initialDetent,
    required this.maxDetent,
    required this.dismissible,
    required this.surfaceColor,
    required this.controller,
  });

  final TwoDetentSheetContentBuilder builder;
  final double initialDetent;
  final double maxDetent;
  final bool dismissible;
  final Color surfaceColor;
  final DraggableScrollableController? controller;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification notification) {
        // A light tick when the sheet settles on either detent, mirroring the
        // physical feedback of native sheets.
        if (notification.extent == initialDetent ||
            notification.extent == maxDetent) {
          HapticFeedback.selectionClick();
        }
        return false;
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialDetent,
        // Keeping the first detent as the minimum when dismissal is disabled
        // prevents accidental drag-dismissal while preserving detent snapping.
        minChildSize: dismissible ? 0 : initialDetent,
        maxChildSize: maxDetent,
        snap: true,
        snapSizes: <double>[initialDetent, maxDetent],
        snapAnimationDuration: const Duration(milliseconds: 260),
        shouldCloseOnMinExtent: dismissible,
        controller: controller,
        builder: (BuildContext context, ScrollController scrollController) {
          const BorderRadius radius = BorderRadius.vertical(
            top: Radius.circular(kTwoDetentCornerRadius),
          );
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Material(
              color: surfaceColor,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: radius),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: ScrollConfiguration(
                  behavior: const TwoDetentSheetScrollBehavior(),
                  child: builder(context, scrollController),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
