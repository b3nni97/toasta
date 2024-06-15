import 'package:flutter/material.dart';
import 'package:toasta/toast_controller.dart';

import 'enum.dart';

class Toast {
  double? height;
  double? width;
  BorderRadiusGeometry? borderRadius;
  bool? darkMode;
  bool? fadeInSubtitle;
  dynamic title;
  dynamic subtitle;
  Widget? leading;
  Widget? trailing;
  VoidCallback? onTap;
  VoidCallback? onAppear;
  VoidCallback? onExit;
  ToastStatus? status;
  Color? backgroundColor;
  Duration? duration;
  Widget? custom;

  ToastController? controller;

  Toast({
    this.width,
    this.height,
    this.borderRadius,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.fadeInSubtitle,
    this.onTap,
    this.onAppear,
    this.onExit,
    this.darkMode,
    this.backgroundColor,
    this.status,
    this.duration,
    this.custom,
    this.controller,
  });
}
