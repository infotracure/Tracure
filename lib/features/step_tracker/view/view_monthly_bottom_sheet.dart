import 'package:flutter/material.dart';

Future<T?> showRoundedBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  double radius = 16,
  bool isScrollControlled = false,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent, // allow rounded corners visible
    builder: (ctx) => _RoundedSheetScaffold(
      radius: radius,
      backgroundColor: backgroundColor,
      child: child,
    ),
  );
}

class _RoundedSheetScaffold extends StatelessWidget {
  final double radius;
  final Widget child;
  final Color? backgroundColor;

  const _RoundedSheetScaffold({
    Key? key,
    required this.radius,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap content in SafeArea to avoid system UI
    return Container(
      // Outer container gives the rounded look
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).canvasColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 40),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // close button on the right
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),

          // content
          child,
        ],
      ),
    );
  }
}
