import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../two_detent_sheet.dart';
import 'demo_data.dart';

/// Scrollable content used to demonstrate the two-detent handoff.
///
/// The key detail is the [scrollController] passed down from
/// [showTwoDetentSheet]: without it the sheet cannot coordinate expansion with
/// the list's scroll offset.
class NearbyPlacesContent extends StatelessWidget {
  const NearbyPlacesContent({
    super.key,
    required this.scrollController,
    required this.surfaceColor,
  });

  final ScrollController scrollController;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color divider = isDark
        ? const Color(0x33FFFFFF)
        : const Color(0xFFEDEDF0);
    final Color secondary = isDark
        ? const Color(0xFF98989F)
        : const Color(0xFF8E8E93);

    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        TwoDetentSheetHeaderSliver(
          title: '附近地点',
          subtitle: '${kNearbyPlaces.length} 个结果 · 按距离排序',
          backgroundColor: surfaceColor,
        ),
        SliverList.separated(
          itemCount: kNearbyPlaces.length,
          itemBuilder: (BuildContext context, int index) {
            final NearbyPlace place = kNearbyPlaces[index];
            return _PlaceRow(
              place: place,
              secondaryColor: secondary,
              onTap: () {
                HapticFeedback.selectionClick().ignore();
                Navigator.of(context).pop<String>(place.name);
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 74,
              color: divider,
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.place,
    required this.secondaryColor,
    required this.onTap,
  });

  final NearbyPlace place;
  final Color secondaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1C1C1E);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 74,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: place.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(place.icon, size: 21, color: place.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      place.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                place.distance,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: secondaryColor.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
