import 'dart:ui' as ui;
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';

// 🚀 1. ĐỊNH NGHĨA DATA MODEL MỚI CHO SLIDE
enum RecapSlideType { spending, badges }

class RecapSlideData {
  final String title;
  final String mainText;
  final String subText;
  final List<UserBadge> badges;
  final RecapSlideType type;
  final bool shouldCelebrate;

  RecapSlideData({
    required this.title,
    required this.mainText,
    required this.subText,
    this.badges = const [],
    required this.type,
    this.shouldCelebrate = false,
  });
}

class StoryRecapScreen extends StatefulWidget {
  final AppColorTheme appColors;
  final String title;
  final List<RecapSlideData> slides;
  final String actionLabel;
  final VoidCallback onFinish;

  const StoryRecapScreen({
    super.key,
    required this.appColors,
    required this.title,
    required this.slides,
    required this.actionLabel,
    required this.onFinish,
  });

  @override
  State<StoryRecapScreen> createState() => _StoryRecapScreenState();
}

class _StoryRecapScreenState extends State<StoryRecapScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late ConfettiController _confettiController;
  late AnimationController _progressController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _progressController =
        AnimationController(
          vsync: this,
          duration: const Duration(
            seconds: 6,
          ), // Tăng thời gian đọc mỗi slide lên 6 giây
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _nextPage();
          }
        });

    _startStory();
  }

  void _startStory() {
    _progressController.forward(from: 0.0);
    if (widget.slides[_currentIndex].shouldCelebrate) {
      _confettiController.play();
      HapticFeedback.successNotification();
    }
  }

  void _nextPage() {
    if (_currentIndex < widget.slides.length - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
      _startStory();
    } else {
      _progressController.stop();
      // Không tự động thoát khi hết slide cuối, chờ user bấm nút hoặc bấm X
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
      _startStory();

      if (!widget.slides[_currentIndex].shouldCelebrate) {
        _confettiController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND (Blobs + Blur)
          _buildAnimatedBackground(),

          // 2. MAIN CONTENT (PAGEVIEW)
          PageView.builder(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // Chỉ chuyển bằng tap
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              return _buildSlideSafeLayer(widget.slides[index]);
            },
          ),

          // 3. GESTURE DETECTOR (Chạm trái/phải để chuyển)
          _buildTouchOverlays(),

          // 4. TOP INDICATORS & HEADER
          SafeArea(
            child: IgnorePointer(
              ignoring: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _buildProgressBars(),
              ),
            ),
          ),

          // Nút Header (Title + Nút X)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: _buildHeader(),
            ),
          ),

          // 5. CONFETTI LAYER
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                Colors.white,
                Colors.amber,
                Colors.pinkAccent,
                Colors.cyan,
              ],
            ),
          ),

          // 🚀 6. NÚT ĐIỀU HƯỚNG TỚI ANALYTICS Ở SLIDE CUỐI CÙNG
          // Đặt ở cuối danh sách Stack để nằm đè lên lớp _buildTouchOverlays
          if (_currentIndex == widget.slides.length - 1)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 28,
                    right: 28,
                    bottom: 24,
                  ),
                  child: _buildActionButton(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // BỌC SLIDE BẰNG LAYOUT BUILDER & SCROLLVIEW ĐỂ CHỐNG TRÀN VIỀN
  Widget _buildSlideSafeLayer(RecapSlideData slide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              // Tăng padding bottom lên 120 để nội dung không bị che khuất bởi Nút Action ở slide cuối
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
                top: 80,
                bottom: 120,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TIÊU ĐỀ SLIDE
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: ui.FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SỐ TIỀN / THÔNG ĐIỆP CHÍNH (ÉP CO GIÃN CHỐNG TRÀN)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      slide.mainText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: ui.FontWeight.w900,
                        color: widget.appColors.primary,
                        height: 1.1,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // HIỂN THỊ DANH SÁCH HUY HIỆU NẾU LÀ SLIDE BADGES
                  if (slide.type == RecapSlideType.badges &&
                      slide.badges.isNotEmpty) ...[
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: slide.badges.map((badge) {
                        return _buildMiniBadge(badge);
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // TEXT PHỤ ĐỂ SO SÁNH / GHI CHÚ
                  if (slide.subText.isNotEmpty)
                    Text(
                      slide.subText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // WIDGET HUY HIỆU THU NHỎ DÙNG RIÊNG CHO RECAP
  Widget _buildMiniBadge(UserBadge badge) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: badge.gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: badge.color.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.white54, width: 1.5),
          ),
          child: Center(child: Icon(badge.icon, size: 30, color: Colors.white)),
        ),
      ],
    );
  }

  // NÚT HÀNH ĐỘNG
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          widget.onFinish();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.appColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: widget.appColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          widget.actionLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.appColors.primary.withValues(alpha: 0.4),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF3366).withValues(alpha: 0.35),
            ),
          ),
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.black.withValues(alpha: 0.2)),
        ),
      ],
    );
  }

  Widget _buildProgressBars() {
    return Row(
      children: List.generate(widget.slides.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: index < _currentIndex
                    ? 1.0
                    : (index == _currentIndex
                          ? _progressController.value
                          : 0.0),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 3,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(CupertinoIcons.xmark, color: Colors.white70, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildTouchOverlays() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: _previousPage,
            behavior: HitTestBehavior.opaque,
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _nextPage,
            behavior: HitTestBehavior.opaque,
          ),
        ),
      ],
    );
  }
}
