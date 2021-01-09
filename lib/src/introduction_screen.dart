library introduction_screen;

import 'dart:async';
import 'dart:math';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class IntroductionScreen extends StatefulWidget {
  /// All pages of the onboarding.
  final List<Widget> pages;

  /// Callback when Done button is pressed
  final VoidCallback onDone;

  /// Callback when page change
  final ValueChanged<int> onChange;

  const IntroductionScreen({
    Key key,
    @required this.pages,
    @required this.onDone,
    this.onChange,
  })  : assert(pages != null),
        assert(
          pages.length > 0,
          'You provide at least one page on introduction screen !',
        ),
        assert(onDone != null),
        super(key: key);

  @override
  IntroductionScreenState createState() => IntroductionScreenState();
}

class IntroductionScreenState extends State<IntroductionScreen> {
  PageController _pageController;
  double _currentPage = 0.0;

  PageController get controller => _pageController;

  @override
  void initState() {
    super.initState();
    final initialPage = min(0, widget.pages.length - 1);
    _currentPage = initialPage.toDouble();
    _pageController = PageController(initialPage: initialPage);
  }

  void next() {
    animateScroll(min(_currentPage.round() + 1, widget.pages.length - 1));
  }

  Future<void> animateScroll(int page) async {
    await _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics is PageMetrics) {
      setState(() => _currentPage = metrics.page);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = (_currentPage.round() == widget.pages.length - 1);

    final nextBtn = ElevatedButton(
      child: Icon(Icons.arrow_forward),
      onPressed: next,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(32, 32)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(64),
        )),
      ),
    );

    final doneBtn = ElevatedButton.icon(
      icon: Icon(Icons.arrow_forward),
      label: Text("Let's Go"),
      onPressed: widget.onDone,
    );

    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView(
              controller: _pageController,
              children: widget.pages,
              physics: const BouncingScrollPhysics(),
              onPageChanged: widget.onChange,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: DotsIndicator(
                        dotsCount: widget.pages.length,
                        position: _currentPage,
                        decorator: DotsDecorator(
                          size: Size(10, 10),
                          activeSize: Size(22, 10),
                          activeColor: colorScheme.primary,
                          activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: isLastPage ? doneBtn : nextBtn,
                    ),
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
