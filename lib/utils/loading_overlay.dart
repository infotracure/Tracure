import 'package:flutter/material.dart';
import 'package:tracure/main.dart';

OverlayEntry? _loaderOverlayEntry;
int _loaderCount = 0;

void showGlobalLoader({bool coverAppBar = false}) {
  _loaderCount++;

  // Only show overlay if this is the first request
  if (_loaderCount > 1) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Skip if all requests completed before callback ran
    if (_loaderCount <= 0) return;

    // Skip if overlay already exists
    if (_loaderOverlayEntry != null) return;

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    // final topOffset = coverAppBar
    //     ? 0.0
    //     : kToolbarHeight + MediaQuery.of(overlay.context).padding.top;
    final topOffset = 0.0;

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
  if (_loaderCount <= 0) return;

  _loaderCount--;

  // Only hide overlay when all requests are done
  if (_loaderCount > 0) return;

  _loaderOverlayEntry?.remove();
  _loaderOverlayEntry = null;
}
