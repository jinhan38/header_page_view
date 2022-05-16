import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:header_page_view/page_view_item.dart';

import 'MeasureUtil.dart';

class HeaderPageView extends StatefulWidget {
  List<Widget>? header;
  double? tabWidth;
  EdgeInsetsGeometry? tabMargin;
  EdgeInsetsGeometry? tabPadding;
  BoxDecoration? tabDecoration;
  List<Widget> tabWidget;
  Widget indicatorWidget;
  Duration pagingDuration;
  List<Widget> pageViewLists;
  bool pageViewItemKeepAlive;
  PageController pageController;
  bool headerAnimation;
  double headerAnimationRatio;
  bool useTabBar;
  TabBar? tabBar;

  HeaderPageView({
    required this.tabWidget,
    required this.indicatorWidget,
    required this.pageViewLists,
    required this.pageController,
    this.header,
    this.tabWidth,
    this.tabMargin,
    this.tabPadding,
    this.tabDecoration = const BoxDecoration(color: Colors.white),
    this.pagingDuration = const Duration(milliseconds: 200),
    this.headerAnimation = true,
    this.pageViewItemKeepAlive = true,
    this.headerAnimationRatio = 0.9,
    this.useTabBar = true,
    this.tabBar,
    Key? key,
  })  :
        // assert(!useTabBar && tabWidget.length > 0,
        //     "Length of tabWidget must be more than 0"),
        assert(
          tabWidget.length == pageViewLists.length,
          'Length of tabWidget and Length of tabWidget must be the same.'
          ' tabWidget.length is ${tabWidget.length}.'
          ' pageViewLists.length is ${pageViewLists.length}',
        ),
        assert(
          headerAnimationRatio > 0.1 && headerAnimationRatio < 1.0,
          'headerAnimationRatio must be between 0.1 and 1.0',
        ),
        super(key: key) {}

  @override
  _HeaderPageViewState createState() => _HeaderPageViewState();
}

class _HeaderPageViewState extends State<HeaderPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Animatable<double> _animationCurve = Tween<double>(begin: 0, end: 1);
  List<ScrollController> _sControllers = [];
  late PageController _pageController;
  bool canPaging = true;
  int _currentIndex = 0;
  double _headerHeight = 0;
  double _headerTop = 0;
  double _tabTop = 0;
  double _beforeScrollOffset = 0;
  double _tabHeight = 0;
  double selectedTabWidth = 0;
  Size? _size;
  double _tabDragPosition = 0;

  @override
  void initState() {
    _setScrollController();
    _pageController = widget.pageController;
    _pageController.addListener(_setPageControllerMove);
    if (widget.useTabBar) {
      _tabController =
          TabController(length: widget.pageViewLists.length, vsync: this);
    } else {
      _animationController =
          AnimationController(vsync: this, duration: widget.pagingDuration);
    }
    super.initState();
  }

  _setScrollController() {
    _sControllers = List.generate(
        widget.pageViewLists.length, (index) => ScrollController());
    for (int i = 0; i < _sControllers.length; i++) {
      _initScrollControllerListener(i);
    }
  }

  _initScrollControllerListener(int index) {
    _sControllers[index].addListener(() {
      double offset = _sControllers[index].offset;
      if (!canPaging &&
          offset >= _headerHeight &&
          _headerTop == -_headerHeight) {
      } else {
        if (offset <= _headerHeight) {
          if (offset <= -_headerTop) {
            if (mounted) {
              setState(() {
                _headerTop = -offset;
                _checkHeaderTopMax();
                _setTabTop();
              });
            }
          } else if (_headerTop > -_headerHeight) {
            if (mounted) {
              setState(() {
                _headerTop = -offset;
                _checkHeaderTopMax();
                _setTabTop();
              });
            }
          }
        } else if (offset > _headerHeight && _headerTop > -_headerHeight) {
          double value = offset - _beforeScrollOffset;
          if (mounted) {
            setState(() {
              _headerTop -= value;
              _checkHeaderTopMax();
              _setTabTop();
            });
          }
        }
      }
      if (_sControllers[_currentIndex].hasClients) {
        _beforeScrollOffset = _sControllers[_currentIndex].offset;
      }
    });
  }

  _checkHeaderTopMax() {
    if (_headerTop < -_headerHeight) {
      _headerTop = -_headerHeight;
    } else if (_headerTop > 0) {
      _headerTop = 0;
    }
  }

  _setPageControllerMove() {
    if (_headerTop != -_headerHeight) {
      _sControllers[_currentIndex].jumpTo(_headerHeight);
    }
    if (_sControllers[_currentIndex].hasClients) {
      _beforeScrollOffset = _sControllers[_currentIndex].offset;
    }
    for (int i = 0; i < _sControllers.length; i++) {
      if (i != _currentIndex &&
          _sControllers[i].hasClients &&
          _sControllers[i].offset < _headerHeight) {
        if (mounted) {
          _sControllers[i].jumpTo(-_headerTop);
          setState(() {
            _setTabTop();
          });
        }
      }
    }
    if (widget.useTabBar) {
      if (!_tabController.indexIsChanging) {
        _tabController.animateTo(
            _calcAnimationValue(_pageController.page!.round()).round(),
            duration: widget.pagingDuration);
        _setCurrentPage(_pageController.page!.round());
      }
    } else {
      if (!_animationController.isAnimating) {
        _animationController.animateTo(
            _calcAnimationValue(_pageController.page!.round()),
            duration: widget.pagingDuration);
        _setCurrentPage(_pageController.page!.round());
      }
    }
  }

  _setTabTop() {
    double tempTabTop = _headerTop + _headerHeight;
    _tabTop = tempTabTop < 0 ? 0 : tempTabTop;
  }

  _playAnimation(int toIndex) {
    _movePageView(toIndex);
    if (widget.useTabBar) {
      _tabController.animateTo(_calcAnimationValue(toIndex).round(),
          duration: widget.pagingDuration);
    } else {
      _animationController.animateTo(_calcAnimationValue(toIndex),
          duration: widget.pagingDuration);
    }
    _setCurrentPage(toIndex);
  }

  _movePageView(int toIndex) {
    if (canPaging) {
      canPaging = false;
      _pageController
          .animateToPage(toIndex,
              duration: widget.pagingDuration, curve: Curves.linear)
          .then((value) {
        canPaging = true;
      });
    }
  }

  _setCurrentPage(int toIndex) {
    _currentIndex = toIndex;
  }

  double _calcAnimationValue(int toIndex) {
    double percent = 1 / (widget.tabWidget.length - 1);
    double animateToValue = 1 * (percent * toIndex);
    return animateToValue;
  }

  @override
  void dispose() {
    if (widget.useTabBar) {
      _tabController.dispose();
    } else {
      _animationController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MeasureSize(
        onChange: (size) {
          _size ??= size;
        },
        child: _body());
  }

  Widget _body() {
    return Stack(
      children: [
        _header(),
        _pageView(),
        Positioned(
          left: 0,
          right: 0,
          top: _tabTop,
          child: Visibility(
            visible: widget.header != null &&
                    widget.header!.isNotEmpty &&
                    _headerHeight == 0
                ? false
                : true,
            child: widget.useTabBar
                ? _tabBar()
                : _customTab(),
          ),
        ),
      ],
    );
  }

  TabBar _tabBar(){
    return  TabBar(
      controller: _tabController,
      tabs: List.generate(
        4,
            (index) => Tab(
          child: Text("iii : $index"),
        ),
      ),
      onTap: (index) {
        _playAnimation(index);
        if (!_sControllers[index].hasClients) {
          if (mounted) {
            setState(() {
              _sControllers[index] = ScrollController(
                  initialScrollOffset: -_headerTop);
              _initScrollControllerListener(index);
            });
          }
        }
      },
      unselectedLabelColor: Colors.grey,
      labelColor: Colors.black,
    );
  }

  Widget _measureHeaderHeight({required Widget child}) {
    if (_headerHeight != 0) {
      return child;
    }
    return MeasureSize(
      onChange: (size) {
        if (mounted) {
          setState(() {
            _headerHeight = size.height;
            _tabTop = _headerHeight;
          });
        }
      },
      child: child,
    );
  }

  Widget _animationHeader() {
    return Opacity(
      opacity:
          _headerHeight == 0 ? 1 : (1 - (-_headerTop / _headerHeight) * 0.5),
      child: Column(
        children: [
          if (_headerHeight == 0) ...[
            ...widget.header!,
          ] else ...[
            ...List.generate(
                widget.header!.length, (index) => widget.header![index]),
          ],
        ],
      ),
    );
  }

  Widget _header() {
    if (widget.header == null || widget.header!.isEmpty) {
      return const SizedBox();
    }
    if (widget.headerAnimation) {
      return Positioned(
        top: _headerTop == 0 ? 0 : _headerTop * widget.headerAnimationRatio,
        left: 0,
        right: 0,
        child: _measureHeaderHeight(
          child: Column(
            children: [
              FittedBox(child: _animationHeader()),
            ],
          ),
        ),
      );
    } else {
      return Positioned(
        top: _headerTop == 0 ? 0 : _headerTop,
        left: 0,
        right: 0,
        child: _measureHeaderHeight(
          child: Container(
            height: _headerHeight == 0 ? null : _headerHeight,
            child: Column(children: widget.header!),
          ),
        ),
      );
    }
  }

  Widget _measureTabHeight({required Widget child}) {
    if (_tabHeight != 0) {
      return child;
    }
    return MeasureSize(
      onChange: (size) {
        if (mounted) {
          setState(() {
            _tabHeight = size.height;
          });
        }
      },
      child: child,
    );
  }

  late TabController _tabController;

  Widget _customTab() {
    _calcSelectedTabWidth();
    return Container(
      color: Colors.white,
      child: _measureTabHeight(
        child: Container(
          height: _tabHeight == 0 ? null : _tabHeight,
          width: widget.tabWidth ?? double.infinity,
          margin: widget.tabMargin,
          padding: widget.tabPadding,
          decoration: widget.tabDecoration,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                // child: SizedBox(width: selectedTabWidth, height: _tabHeight == 0 ? null : _tabHeight, child: widget.indicatorWidget),
                child: Container(
                    constraints: BoxConstraints(maxHeight: _tabHeight),
                    width: selectedTabWidth,
                    child: widget.indicatorWidget),
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(
                        lerpDouble(-1, 1,
                            _animationCurve.evaluate(_animationController))!,
                        0),
                    child: child,
                  );
                },
              ),
              SizedBox(
                height: _tabHeight == 0 ? null : _tabHeight,
                child: Row(
                  children: _unSelectedTabWidget((index) {
                    if (mounted) {
                      setState(() => _headerTop = -_headerHeight);
                    }
                    _playAnimation(index);
                    if (!_sControllers[index].hasClients) {
                      if (mounted) {
                        setState(() {
                          _sControllers[index] = ScrollController(
                              initialScrollOffset: -_headerTop);
                          _initScrollControllerListener(index);
                        });
                      }
                    }
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _calcSelectedTabWidth() {
    double marginWidth = 0;
    double paddingWidth = 0;
    if (selectedTabWidth == 0) {
      if (widget.tabMargin != null) {
        marginWidth = widget.tabMargin!.horizontal;
      }
      if (widget.tabPadding != null) {
        paddingWidth = widget.tabPadding!.horizontal;
      }
      if (widget.tabWidth == null) {
        selectedTabWidth =
            (MediaQuery.of(context).size.width - marginWidth - paddingWidth) /
                widget.tabWidget.length;
      } else {
        selectedTabWidth = (widget.tabWidth! - marginWidth - paddingWidth) /
            widget.tabWidget.length;
      }
    }
  }

  List<Widget> _unSelectedTabWidget(Function(int) onTap) {
    return List.generate(
      widget.tabWidget.length,
      (index) => Expanded(
        child: GestureDetector(
          onVerticalDragDown: (details) {
            _tabDragPosition = details.globalPosition.dy;
          },
          onVerticalDragUpdate: (details) {
            /// headerTop 값이 0일 때
            /// 아래에서 위로 드래그 한 경우 details.globalPosition.dy 값은 더 작아진다.
            /// 위에서 아래로 그래그한 경우  details.globalPosition.dy 값은 더 커진다.
            /// _headerTop 값이 0이고, 위에서 아래로 그래그 한 경우 아무 효과 없다.
            if (_tabDragPosition != details.globalPosition.dy &&
                !(_tabDragPosition < details.globalPosition.dy &&
                    _headerTop.abs() == 0)) {
              _sControllers[_currentIndex].jumpTo(
                  _sControllers[_currentIndex].offset +
                      (_tabDragPosition - details.globalPosition.dy));
            }
            _tabDragPosition = details.globalPosition.dy;
          },
          onVerticalDragEnd: (details) => _tabDragPosition = 0,
          onVerticalDragCancel: () => _tabDragPosition = 0,
          behavior: HitTestBehavior.translucent,
          onTap: () => onTap(index),
          child: Container(child: widget.tabWidget[index]),
        ),
      ),
    );
  }

  Widget _pageView() {
    return PageView(
      controller: _pageController,
      children: List.generate(
          widget.pageViewLists.length,
          (index) =>
              _pageViewItem(widget.pageViewLists[index], _sControllers[index])),
    );
  }

  Widget _pageViewItem(Widget child, ScrollController scrollController) {
    double topPadding = 0;
    if (widget.header != null && widget.header!.isNotEmpty) {
      if (_headerHeight == 0) {
        topPadding = MediaQuery.of(context).size.height;
      } else {
        topPadding = _headerHeight;
      }
    }
    return HeaderPageViewItem(
      widget: child,
      pageViewItemKeepAlive: widget.pageViewItemKeepAlive,
      scrollController: scrollController,
      topPadding: topPadding,
      topMarin: _tabHeight,
      minHeight: _size == null
          ? MediaQuery.of(context).size.height
          : _size!.height - _tabHeight,
    );
  }
}
