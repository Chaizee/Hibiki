import 'package:flutter/material.dart';

/// Extra top inset for the first three tab screens (Listen, History, Notes).
abstract final class ScreenLayout {
  static const double topContentInset = 28;

  static EdgeInsets screenPadding(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + topContentInset;
    return EdgeInsets.fromLTRB(20, top, 20, 24);
  }
}
