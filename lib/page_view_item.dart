import 'package:flutter/material.dart';

class HeaderPageViewItem extends StatefulWidget {
  Widget widget;
  bool pageViewItemKeepAlive;
  ScrollController scrollController;
  double topMarin;
  double topPadding;
  double minHeight;

  HeaderPageViewItem({
    required this.widget,
    required this.pageViewItemKeepAlive,
    required this.scrollController,
    required this.topMarin,
    required this.topPadding,
    required this.minHeight,
    Key? key,
  }) : super(key: key);

  @override
  _HeaderPageViewItemState createState() => _HeaderPageViewItemState();
}

class _HeaderPageViewItemState extends State<HeaderPageViewItem> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: EdgeInsets.only(top: widget.topPadding),
      controller: widget.scrollController,
      shrinkWrap: true,
      children: [
        Container(
          margin: EdgeInsets.only(top: widget.topMarin),
          constraints: BoxConstraints(minHeight: widget.minHeight),
          color: Colors.white,
          child: widget.widget,
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
