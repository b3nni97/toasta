import 'package:flutter/widgets.dart';

class ToastController extends ChangeNotifier {
  final GlobalKey toastKey = GlobalKey();

  // Callback which is triggered when the Toast
  // should schedule it´s disappearance.
  // Returns a future after the toast is disappeared.
  Future Function()? onScheduleDisappear;
  bool _onScheduleDisappared = false;

  Future scheduleDisappear() async {
    if (_onScheduleDisappared) return;

    _onScheduleDisappared = true;
    return onScheduleDisappear?.call();
  }
}
