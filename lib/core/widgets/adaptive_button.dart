import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An adaptive button that renders a Material [ElevatedButton] on Android
/// and a [CupertinoButton.filled] on iOS.
class AdaptiveButton extends StatelessWidget {
  /// Creates an adaptive button.
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isDestructive = false,
  });

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The child widget of the button.
  final Widget child;

  /// Whether the button represents a destructive action (e.g. delete).
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: child,
      );
    }

    if (isDestructive) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
