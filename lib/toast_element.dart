import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toasta/provider.dart';

import 'enum.dart';
import 'model.dart';

class ToastElement extends StatefulWidget {
  const ToastElement({Key? key, required this.element}) : super(key: key);

  final Toast element;
  @override
  _ToastElementState createState() => _ToastElementState();
}

class _ToastElementState extends State<ToastElement>
    with TickerProviderStateMixin {
  late final AnimationController _startController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<Offset> _startOffsetFloat =
      Tween(begin: const Offset(0.0, -0.20), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _startController,
      curve: Curves.easeOutQuint,
      reverseCurve: Curves.easeOut,
    ),
  );
  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.easeOutQuint,
  );
  late Timer disappearTimer;

  late double dragDeltaY = 0;

  final GlobalKey customWidgetKey = GlobalKey();
  late double? customWidgetHeight;

  bool _isDisappeared = false;

  @override
  void initState() {
    _startController.forward().then((_) {
      if (widget.element.onAppear != null) {
        widget.element.onAppear!();
      }
    });
    _scaleController.forward();
    if (widget.element.fadeInSubtitle == false) {
      _fadeController.duration = const Duration(milliseconds: 0);
      _fadeController.forward();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_isDisappeared && mounted) {
          _fadeController.forward();
        }
      });
    }
    disappearTimer = Timer(
        widget.element.duration != null
            ? widget.element.duration!
            : const Duration(seconds: 3), () {
      disappear();
    });

    widget.element.controller?.onScheduleDisappear = () async {
      // This is called if the toast should disappear because another
      // toast should be shown.
      // This toast disappears after waiting for 1 second.
      disappearTimer.cancel();
      disappearTimer = Timer(const Duration(milliseconds: 1000), () {
        disappear();
      });
    };

    if (widget.element.custom != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        calcWidgetHeight();
      });
    }

    super.initState();
  }

  void disappear() {
    if (!mounted || _isDisappeared) return;

    _isDisappeared = true;

    ToastaProvider toastaProvider =
        Provider.of<ToastaProvider>(context, listen: false);

    toastaProvider.prePop(widget.element);

    _startController.reverse().then((value) {
      if (widget.element.onExit != null) {
        widget.element.onExit!();
      }

      toastaProvider.popped(widget.element);
    });
  }

  @override
  void dispose() {
    _startController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /**
   * Calculate the widget height if a user has set a custom widget
   * This is needed to detect the gestures correctly
   */
  calcWidgetHeight() {
    final keyContext = customWidgetKey.currentContext;

    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;

      customWidgetHeight = box.size.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _startOffsetFloat,
      child: ScaleTransition(
        scale: _animation,
        alignment: Alignment.topCenter,
        child: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Container(
              margin: kIsWeb ? const EdgeInsets.only(top: 16) : null,
              width: double.infinity,
              child: Container(
                decoration: widget.element.custom == null
                    ? BoxDecoration(
                        borderRadius: widget.element.borderRadius != null
                            ? widget.element.borderRadius!
                            : const BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                        boxShadow: widget.element.darkMode == true
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.13),
                                  spreadRadius: 3,
                                  blurRadius: 20,
                                  offset: const Offset(0, 9),
                                )
                              ])
                    : null,
                child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      disappearTimer.cancel();

                      dragDeltaY += details.delta.dy;

                      _startController.value = (1 +
                              (dragDeltaY /
                                  (customWidgetHeight ??
                                      widget.element.height ??
                                      72)))
                          .clamp(0.0, 1.0);
                    },
                    onVerticalDragEnd: (dragEndDetail) {
                      dragDeltaY = 0;

                      disappearTimer = Timer(
                          widget.element.duration != null
                              ? widget.element.duration!
                              : const Duration(seconds: 3), () {
                        disappear();
                      });

                      if (_startController.value < 0.5 ||
                          dragEndDetail.velocity.pixelsPerSecond.dy < -8) {
                        disappearTimer.cancel();
                        disappear();
                      } else {
                        _startController.forward();
                      }
                    },
                    child: widget.element.custom != null
                        ? KeyedSubtree(
                            key: customWidgetKey,
                            child: widget.element.custom!,
                          )
                        : const SizedBox.shrink()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color toastBackgroundColor() {
    if (widget.element.backgroundColor != null) {
      return widget.element.backgroundColor!;
    }
    return widget.element.darkMode == true ? Colors.grey : Colors.white;
  }

  List<Widget> toastStatus() {
    if (widget.element.status != null) {
      Widget icon = Container();
      switch (widget.element.status) {
        case ToastStatus.failed:
          icon = const CircleAvatar(
              backgroundColor: Colors.red,
              child:
                  Icon(Icons.highlight_remove, size: 20, color: Colors.white));
          break;
        case ToastStatus.warning:
          icon = const CircleAvatar(
              backgroundColor: Colors.yellow,
              child:
                  Icon(Icons.warning_rounded, size: 20, color: Colors.black));
          break;
        case ToastStatus.success:
          icon = const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.check_rounded, size: 20, color: Colors.white));
          break;
        case ToastStatus.info:
          icon = const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.info_outline, size: 20, color: Colors.white));
          break;
        default:
          break;
      }

      return [
        SizedBox(
          width: 32,
          height: 32,
          child: icon,
        ),
        const SizedBox(width: 10),
      ];
    }
    return [];
  }

  List<Widget> toastSubtitle() {
    if (widget.element.subtitle == null) {
      return [Container()];
    }
    return [
      FadeTransition(
          opacity: _fadeController.drive(CurveTween(curve: Curves.easeInOut)),
          child: widget.element.subtitle.runtimeType == String
              ? Text(
                  widget.element.subtitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w300),
                )
              : widget.element.subtitle),
      const SizedBox(height: 8)
    ];
  }
}
