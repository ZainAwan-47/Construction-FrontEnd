import 'package:flutter/material.dart';

class AnimatedTabStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const AnimatedTabStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<AnimatedTabStack> createState() => _AnimatedTabStackState();
}

class _AnimatedTabStackState extends State<AnimatedTabStack> {
  late final PageController _pageController = PageController(
    initialPage: widget.index,
  );

  @override
  void didUpdateWidget(covariant AnimatedTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index && _pageController.hasClients) {
      _pageController.animateToPage(
        widget.index,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final child in widget.children) _RetainedTab(child: child),
      ],
    );
  }
}

class _RetainedTab extends StatefulWidget {
  final Widget child;

  const _RetainedTab({required this.child});

  @override
  State<_RetainedTab> createState() => _RetainedTabState();
}

class _RetainedTabState extends State<_RetainedTab>
    with AutomaticKeepAliveClientMixin<_RetainedTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
