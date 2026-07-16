import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _illustrationController;
  late final AnimationController _fadeController;

  static const _pages = [
    _OnboardingPage(
      title: 'Scan\nTextbooks',
      subtitle:
          'Take a picture of any German text, and Klarify instantly builds vocabulary cards.',
      icon: Icons.document_scanner_rounded,
      accentColor: Color(0xFF38B6FF),
      gradientColors: [
        Color(0xFF0F3A66), // Dark Blue
        Color(0xFF1E6C93), // Mid Blue
      ],
      illustrationElements: [
        _FloatingElement(
          icon: Icons.camera_alt_rounded,
          x: 0.15,
          y: 0.2,
          size: 28,
          delay: 0,
        ),
        _FloatingElement(
          icon: Icons.auto_awesome_rounded,
          x: 0.75,
          y: 0.15,
          size: 22,
          delay: 0.3,
        ),
        _FloatingElement(
          icon: Icons.bolt_rounded,
          x: 0.82,
          y: 0.65,
          size: 24,
          delay: 0.6,
        ),
        _FloatingElement(
          icon: Icons.auto_stories_rounded,
          x: 0.12,
          y: 0.7,
          size: 26,
          delay: 0.2,
        ),
      ],
    ),
    _OnboardingPage(
      title: 'Study\nSmart',
      subtitle:
          'Our spaced repetition system ensures you review words right when you\'re about to forget them.',
      icon: Icons.psychology_rounded,
      accentColor: Color(0xFFFACC15),
      gradientColors: [
        Color(0xFF5C3D20), // Dark Brown
        Color(0xFF92541A), // Mid Orange
      ],
      illustrationElements: [
        _FloatingElement(
          icon: Icons.replay_rounded,
          x: 0.18,
          y: 0.18,
          size: 24,
          delay: 0.1,
        ),
        _FloatingElement(
          icon: Icons.star_rounded,
          x: 0.78,
          y: 0.22,
          size: 20,
          delay: 0.4,
        ),
        _FloatingElement(
          icon: Icons.style_rounded,
          x: 0.80,
          y: 0.68,
          size: 26,
          delay: 0.5,
        ),
        _FloatingElement(
          icon: Icons.schedule_rounded,
          x: 0.10,
          y: 0.65,
          size: 22,
          delay: 0.3,
        ),
      ],
    ),
    _OnboardingPage(
      title: 'Build Your\nVocab',
      subtitle:
          'Track your mastery over time with beautiful, organized decks and detailed analytics.',
      icon: Icons.insights_rounded,
      accentColor: Color(0xFF34D399),
      gradientColors: [
        Color(0xFF064E3B), // Dark Teal
        Color(0xFF0D9488), // Teal 600
      ],
      illustrationElements: [
        _FloatingElement(
          icon: Icons.pie_chart_rounded,
          x: 0.15,
          y: 0.22,
          size: 24,
          delay: 0.2,
        ),
        _FloatingElement(
          icon: Icons.trending_up_rounded,
          x: 0.80,
          y: 0.18,
          size: 22,
          delay: 0,
        ),
        _FloatingElement(
          icon: Icons.bar_chart_rounded,
          x: 0.78,
          y: 0.70,
          size: 26,
          delay: 0.4,
        ),
        _FloatingElement(
          icon: Icons.timeline_rounded,
          x: 0.12,
          y: 0.68,
          size: 22,
          delay: 0.6,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _illustrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _illustrationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => const AppShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _OnboardingPageView(
                page: page,
                animationController: _illustrationController,
                screenHeight: screenHeight,
              );
            },
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: AnimatedOpacity(
              opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(right: 10),
                        height: 8,
                        width: _currentPage == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].accentColor
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),

                  // CTA Button
                  _AnimatedCTAButton(
                    isLastPage: _currentPage == _pages.length - 1,
                    accentColor: _pages[_currentPage].accentColor,
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _goToPage(_currentPage + 1);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Page Data Model

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.illustrationElements,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final List<_FloatingElement> illustrationElements;
}

class _FloatingElement {
  const _FloatingElement({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
  });
  final IconData icon;
  final double x;
  final double y;
  final double size;
  final double delay;
}

// Page View Widget

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.animationController,
    required this.screenHeight,
  });
  final _OnboardingPage page;
  final AnimationController animationController;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            page.gradientColors[0],
            page.gradientColors[1],
            page.gradientColors[1].withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Illustration area
            Expanded(
              flex: 5,
              child: _IllustrationArea(
                page: page,
                animationController: animationController,
              ),
            ),

            // Text content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      page.title,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Space for bottom controls
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// Illustration Area

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({
    required this.page,
    required this.animationController,
  });
  final _OnboardingPage page;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerSize = constraints.maxWidth * 0.42;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring behind center icon
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final scale = 1.0 + animationController.value * 0.08;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: centerSize + 40,
                    height: centerSize + 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: page.accentColor.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Outer ring
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final scale = 1.0 + (1 - animationController.value) * 0.05;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: centerSize + 90,
                    height: centerSize + 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: page.accentColor.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Center icon container
            Container(
              width: centerSize,
              height: centerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.accentColor.withValues(alpha: 0.2),
                    page.accentColor.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: page.accentColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                page.icon,
                size: centerSize * 0.4,
                color: page.accentColor,
              ),
            ),

            // Floating elements
            ...page.illustrationElements.map((element) {
              return Positioned(
                left: constraints.maxWidth * element.x - element.size / 2,
                top: constraints.maxHeight * element.y - element.size / 2,
                child: _FloatingIcon(
                  element: element,
                  accentColor: page.accentColor,
                  animationController: animationController,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// Floating Icon Widget

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.element,
    required this.accentColor,
    required this.animationController,
  });
  final _FloatingElement element;
  final Color accentColor;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Offset phase per element for organic movement
        final phase = element.delay * math.pi * 2;
        final yOffset =
            math.sin(animationController.value * math.pi + phase) * 6;
        final opacity =
            0.5 + math.sin(animationController.value * math.pi + phase) * 0.3;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Container(
            width: element.size + 20,
            height: element.size + 20,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              element.icon,
              size: element.size,
              color: accentColor.withValues(alpha: opacity.clamp(0.3, 0.8)),
            ),
          ),
        );
      },
    );
  }
}

// CTA Button

class _AnimatedCTAButton extends StatelessWidget {
  const _AnimatedCTAButton({
    required this.isLastPage,
    required this.accentColor,
    required this.onPressed,
  });
  final bool isLastPage;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 56,
        padding: EdgeInsets.symmetric(
          horizontal: isLastPage ? 32 : 24,
        ),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                isLastPage ? 'Get Started' : 'Next',
                key: ValueKey(isLastPage),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLastPage
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
