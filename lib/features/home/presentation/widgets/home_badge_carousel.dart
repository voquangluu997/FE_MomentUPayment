import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';
import 'package:moment_u_payment/core/features/badges/badge_service.dart';
import 'package:moment_u_payment/core/utils/gamification_utils.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/core/features/badges/screens/badge_gallery_page.dart';

class HomeBadgeCarousel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const HomeBadgeCarousel({super.key, required this.onClose});

  @override
  ConsumerState<HomeBadgeCarousel> createState() => _HomeBadgeCarouselState();
}

class _HomeBadgeCarouselState extends ConsumerState<HomeBadgeCarousel> {
  late PageController _pageController;
  Timer? _scrollTimer;
  Timer? _hideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // 1. Tự động chuyển slide mỗi  giây
    _scrollTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        final displayItems = _getDisplayItems(ref);
        if (displayItems.length <= 1) return;

        int nextPage = _currentPage + 1;
        if (nextPage >= displayItems.length) nextPage = 0;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    // // 2. Tự động ẩn toàn bộ slider sau 30 giây
    // _hideTimer = Timer(const Duration(seconds: 30), () {
    //   if (mounted) {
    //     widget.onClose();
    //   }
    // });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _hideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<dynamic> _getDisplayItems(WidgetRef ref) {
    final unlockedTypes = ref.read(unlockedBadgesProvider);
    final allUnlocked = GamificationUtils.allBadges
        .where((b) => unlockedTypes.contains(b.type))
        .toList();

    bool isOnlyFirstBlood =
        allUnlocked.length == 1 &&
        allUnlocked.first.type == BadgeType.firstBlood;

    List<dynamic> items = [];
    items.addAll(allUnlocked);

    if (allUnlocked.isEmpty || isOnlyFirstBlood) {
      items.add(null);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayItems = _getDisplayItems(ref);

    if (displayItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Tiêu đề bên trái, Nút đóng bên phải
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tiêu đề
                Text(
                  l10n.badgeTabTitle, // Đảm bảo key này tồn tại trong file l10n của bạn
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                // Nút đóng
                GestureDetector(
                  onTap: widget.onClose,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.closeButton,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 14,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // KHỐI SLIDER
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const BadgeGalleryPage()),
              );
            },
            child: SizedBox(
              height: 92,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  if (item == null) {
                    return const HomeBadgeCard(isLocked: true);
                  } else {
                    return HomeBadgeCard(badge: item as UserBadge);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🚀 WIDGET REUSABLE: Card hiển thị Badge hoặc Mystery Card
class HomeBadgeCard extends StatefulWidget {
  final UserBadge? badge;
  final bool isLocked;

  const HomeBadgeCard({super.key, this.badge, this.isLocked = false});

  @override
  State<HomeBadgeCard> createState() => _HomeBadgeCardState();
}

class _HomeBadgeCardState extends State<HomeBadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheenController;
  late Animation<double> _sheenAnimation;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _sheenAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _sheenController, curve: Curves.easeInOut),
    );

    if (!widget.isLocked) {
      _sheenController.repeat();
    }
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final appColors = ref.watch(appColorsProvider);
        final l10n = AppLocalizations.of(context)!;
        final isLocked = widget.isLocked || widget.badge == null;
        final lockedColor = const Color(0xFF8A2BE2);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isLocked
                ? const Color(0xFF161622)
                : appColors.cardBackground,
            border: Border.all(
              color: isLocked
                  ? lockedColor.withValues(alpha: 0.5)
                  : widget.badge!.color.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLocked
                    ? lockedColor.withValues(alpha: 0.2)
                    : widget.badge!.color.withValues(alpha: 0.08),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: isLocked
                              ? const LinearGradient(
                                  colors: [Colors.black87, Color(0xFF8A2BE2)],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: widget.badge!.gradientColors,
                                ),
                        ),
                        child: Center(
                          child: Icon(
                            isLocked
                                ? CupertinoIcons.lock_fill
                                : widget.badge!.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLocked
                                  ? "???"
                                  : widget.badge!.getLocalizedTitle(l10n),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isLocked
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : appColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLocked
                                  ? l10n.badgeLockedSecretDesc
                                  : widget.badge!.getLocalizedDesc(l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isLocked
                                    ? Colors.white54
                                    : appColors.textMuted.withValues(
                                        alpha: 0.8,
                                      ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Hiệu ứng ánh kim nếu đã mở khóa
                if (!isLocked)
                  AnimatedBuilder(
                    animation: _sheenController,
                    builder: (context, _) => Positioned.fill(
                      child: Align(
                        alignment: Alignment(_sheenAnimation.value, 0.0),
                        child: Transform.rotate(
                          angle: pi / 6,
                          child: Container(
                            width: 32,
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
