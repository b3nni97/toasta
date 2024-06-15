import 'package:flutter/material.dart';
import 'package:toasta/toast_controller.dart';

import 'model.dart';

class ToastaProvider extends ChangeNotifier {
  final Set<Toast> _currentToastingsSet = {};
  List<Toast>? currentToastings;
  List<Toast> toastQueues = [];

  void check() async {
    if (toastQueues.isEmpty) return;

    notifyListeners();

    final currentToast = toastQueues.first;

    if (!_currentToastingsSet.contains(currentToast)) {
      _currentToastingsSet.add(currentToast);
      currentToastings ??= [];
      currentToastings?.add(currentToast);
    }

    final toastQueuesLength = toastQueues.length;

    if (toastQueuesLength > 1) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          currentToast.controller?.scheduleDisappear();
        },
      );
    }

    notifyListeners();
  }

  void toast(Toast toast) {
    toast.controller ??= ToastController();

    toastQueues.add(toast);
    check();
  }

  void prePop(Toast toast) {
    toastQueues.remove(toast);
    check();
  }

  void popped(Toast toast) {
    currentToastings?.remove(toast);
    _currentToastingsSet.remove(toast);

    if (currentToastings?.isEmpty ?? false) {
      currentToastings = null;
      _currentToastingsSet.clear();
    }

    notifyListeners();
  }
}
