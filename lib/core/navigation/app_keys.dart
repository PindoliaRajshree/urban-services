// File: lib/core/navigation/app_keys.dart
// Purpose: Global keys shared by the router and by code that has no
// BuildContext of its own (snackbars shown from notifiers, the 401 logout).

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
