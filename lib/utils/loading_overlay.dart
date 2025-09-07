import 'package:flutter/material.dart';
import 'package:tracure/main.dart';

//TODO: Concurrent api calls loader hides
//TODO: When loader is in progess and view is poped, loader is not removed
OverlayEntry? _loaderOverlayEntry;
bool isLoadingShown = false;

void showGlobalLoader({bool coverAppBar = false}) {
  if (isLoadingShown) return;
  isLoadingShown = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!isLoadingShown)
      return; // 🔑 skip if hideGlobalLoader was already called

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      isLoadingShown = false;
      return;
    }

    final topOffset = coverAppBar
        ? 0.0
        : kToolbarHeight + MediaQuery.of(overlay.context).padding.top;

    _loaderOverlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        top: topOffset,
        child: Container(
          color: Colors.white.withValues(alpha: .5),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      ),
    );

    overlay.insert(_loaderOverlayEntry!);
  });
}

void hideGlobalLoader() {
  if (!isLoadingShown) return;
  _loaderOverlayEntry?.remove();
  _loaderOverlayEntry = null;
  isLoadingShown = false;
}
