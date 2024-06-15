library toasta;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toasta/provider.dart';
import 'package:toasta/toast_element.dart';

import 'model.dart';

export 'enum.dart';
export 'model.dart';

class ToastaContainer extends StatefulWidget {
  const ToastaContainer({Key? key, required this.child}) : super(key: key);

  final Widget child;
  @override
  _ToastaContainerState createState() => _ToastaContainerState();
}

class _ToastaContainerState extends State<ToastaContainer> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ToastaProvider>(
      create: (context) => ToastaProvider(),
      child: Consumer<ToastaProvider>(
        builder: (context, _toastaProvider, child) {
          return Stack(
            children: [
              child!,
              if (_toastaProvider.currentToastings != null)
                for (var toastElement in _toastaProvider.currentToastings!)
                  ToastElement(
                    key: toastElement.controller?.toastKey,
                    element: toastElement,
                  ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

class Toasta {
  final BuildContext context;

  Toasta(this.context);

  toast(Toast toast) {
    ToastaProvider toastaProvider =
        Provider.of<ToastaProvider>(context, listen: false);
    toastaProvider.toast(toast);
  }
}
