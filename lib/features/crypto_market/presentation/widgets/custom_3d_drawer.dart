import 'package:flutter/material.dart';

import 'app_drawer_menu.dart';
import 'custom_rounded_app_bar.dart';

class Custom3DAnimatedDrawer extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onIndexSelected;
  final String title;

  const Custom3DAnimatedDrawer({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onIndexSelected,
    required this.title,
  });

  @override
  State<Custom3DAnimatedDrawer> createState() => Custom3DAnimatedDrawerState();
}

class Custom3DAnimatedDrawerState extends State<Custom3DAnimatedDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void closeDrawer() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Vibrant royal blue for Light mode (matching reference design), sleek dark navy for Dark mode
    final drawerBg = isDark ? const Color(0xFF0F172A) : const Color(0xFF3B62FF);

    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamically scale slide displacement and drawer width across mobile, tablet, and desktop
    final maxSlide = (screenWidth * 0.65).clamp(290.0, 430.0);
    final drawerWidth = (maxSlide - 42.0).clamp(248.0, 385.0);

    return Scaffold(
      backgroundColor: drawerBg,
      body: Stack(
        children: [
          // ── 1. Background Drawer Menu Screen ──────────────────────────────────
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: drawerWidth,
            child: AppDrawerMenu(
              selectedIndex: widget.selectedIndex,
              isDesktop: false,
              drawerWidth: drawerWidth,
              onIndexSelected: (index) {
                widget.onIndexSelected(index);
                closeDrawer();
              },
              onCloseDrawer: closeDrawer,
            ),
          ),

          // ── 2. Foreground Sliding & Scaling Main Screen ──────────────────────────
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animVal = CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOutCubic,
              ).value;

              final slide = maxSlide * animVal;
              final scale = 1.0 - (animVal * 0.18);
              final borderRadius = 32.0 * animVal;

              return Transform(
                // ignore: deprecated_member_use
                transform: Matrix4.identity()
                  // ignore: deprecated_member_use
                  ..translate(slide)
                  // ignore: deprecated_member_use
                  ..scale(scale),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: animVal > 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.35 * animVal,
                              ),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(-12, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.15 * animVal,
                              ),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(-4, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Scaffold(
                      appBar: CustomRoundedAppBar(
                        title: widget.title,
                        leading: IconButton(
                          icon: AnimatedIcon(
                            icon: AnimatedIcons.menu_close,
                            progress: _controller,
                            color: Colors.white,
                          ),
                          onPressed: toggleDrawer,
                        ),
                      ),
                      body: GestureDetector(
                        onTap: _isOpen ? closeDrawer : null,
                        behavior: HitTestBehavior.translucent,
                        child: IgnorePointer(
                          ignoring: _isOpen,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
