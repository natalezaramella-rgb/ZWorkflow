import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An adaptive scaffold that renders a Material [Scaffold] with a [Drawer]
/// on Android and a [CupertinoPageScaffold] on iOS.
class AdaptiveScaffold extends StatelessWidget {
  /// Creates an adaptive scaffold.
  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.drawer,
    this.floatingActionButton,
    this.actions,
  });

  /// The title displayed in the app bar / navigation bar.
  final String title;

  /// The main content of the scaffold.
  final Widget body;

  /// An optional drawer (used only on Material/Android).
  final Widget? drawer;

  /// An optional floating action button (used only on Material/Android).
  final Widget? floatingActionButton;

  /// Optional trailing actions for the app bar.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: actions != null && actions!.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              : null,
        ),
        child: SafeArea(child: body),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
