import 'package:flutter/material.dart';

/// Global keys to access top-level states without BuildContext
class GlobalKeys {
  GlobalKeys._();

  /// Used to show Snackbars globally anywhere in the app
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Used for global navigation if needed
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
