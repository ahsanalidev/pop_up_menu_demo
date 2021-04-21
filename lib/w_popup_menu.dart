import 'package:flutter/material.dart';
import 'triangle_painter.dart';

const double _kMenuScreenPadding = 8.0;

class WPopupMenu extends StatefulWidget {
  WPopupMenu({
    Key key,
    @required this.child,
    @required this.body,
    this.backgroundColor = Colors.white,
    this.menuWidth = 250,
    this.menuHeight = 42,
  });

  final Widget child;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final Widget body;

  @override
  _WPopupMenuState createState() => _WPopupMenuState();
}

class _WPopupMenuState extends State<WPopupMenu> {
  double width;
  double height;
  RenderBox button;
  RenderBox overlay;
  OverlayEntry entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      width = context.size.width;
      height = context.size.height;
      button = context.findRenderObject();
      overlay = Overlay.of(context).context.findRenderObject();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (entry != null) {
          removeOverlay();
        }
        return Future.value(true);
      },
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: widget.child,
          onTap: () {
            onTap();
          }),
    );
  }

  void onTap() {
    Widget menuWidget = _MenuPopWidget(
      context,
      height,
      width,
      widget.backgroundColor,
      widget.menuWidth,
      widget.menuHeight,
      button,
      overlay,
      widget.body,
    );

    entry = OverlayEntry(builder: (context) {
      return menuWidget;
    });
    Overlay.of(context).insert(entry);
  }

  void removeOverlay() {
    entry.remove();
    entry = null;
  }
}

enum PressType {
  // 长按
  longPress,
  // 单击
  singleClick,
}

class _MenuPopWidget extends StatefulWidget {
  final BuildContext btnContext;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final double _height;
  final double _width;
  final RenderBox button;
  final RenderBox overlay;
  final Widget body;

  _MenuPopWidget(
    this.btnContext,
    this._height,
    this._width,
    this.backgroundColor,
    this.menuWidth,
    this.menuHeight,
    this.button,
    this.overlay,
    this.body,
  );

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  final double _triangleHeight = 10;

  RelativeRect position;

  @override
  void initState() {
    super.initState();
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
      ),
      Offset.zero & widget.overlay.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
                position,
                widget.menuHeight + _triangleHeight,
                Directionality.of(widget.btnContext),
                widget._width,
                widget.menuWidth,
                widget._height),
            child: SizedBox(
              height: widget.menuHeight + _triangleHeight,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomPaint(
                      size: Size(300, _triangleHeight),
                      painter: TrianglePainter(
                        color: widget.backgroundColor,
                        position: position,
                        isInverted: true,
                        size: widget.button.size,
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            child: Container(
                              color: widget.backgroundColor,
                              height: widget.menuHeight,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // 中间是ListView
                              _buildList(widget.body),

                              // 右箭头：判断是否有箭头，如果有就显示，没有就不显示
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(Widget overlayBody) {
    return overlayBody;
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.position, this.selectedItemOffset,
      this.textDirection, this.width, this.menuWidth, this.height);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // The distance from the top of the menu to the middle of selected item.
  //
  // This will be null if there's no item to position in this way.
  final double selectedItemOffset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  final double width;
  final double height;
  final double menuWidth;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest -
        const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.
    double y;
    if (selectedItemOffset == null) {
      y = position.top;
    } else {
      y = position.top +
          (size.height - position.top - position.bottom) / 2.0 -
          selectedItemOffset;
    }

    // Find the ideal horizontal position.
    double x;

    if (childSize.width < width) {
      x = position.left + (width - childSize.width) / 2;
    } else {
      if (position.left > size.width - (position.left + width)) {
        if (size.width - (position.left + width) >
            childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left + width - childSize.width;
        }
      } else if (position.left < size.width - (position.left + width)) {
        if (position.left > childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else
          x = position.left;
      } else {
        x = position.right - width / 2 - childSize.width / 2;
      }
    }

    if (y < _kMenuScreenPadding)
      y = _kMenuScreenPadding;
    else if (y + childSize.height > size.height - _kMenuScreenPadding)
      y = size.height - childSize.height;
    else if (y < childSize.height * 2) {
      y = position.top + height;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
