import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:urban_services/core/navigation/app_keys.dart';
import 'package:urban_services/core/session/token_store.dart';
import 'package:urban_services/core/themes/theme.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

Future<void> main() async {
  // Ensure the Flutter binding is initialized (REQUIRED)
  WidgetsFlutterBinding.ensureInitialized();

  // System Setup
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  await Firebase.initializeApp();

  // Initialize SharedPreferences, then the secure auth token (which reads
  // a flag from SharedPreferences).
  await SharedPreferencesHelper.init();
  await TokenStore.init();

  // Force Hybrid Composition for the google_maps_flutter map on Android.
  // Without this, some devices/emulators (especially those with software
  // or older GPU drivers) render the map as a solid color placeholder
  // (commonly a yellow or black box) instead of actual tiles — a known
  // rendering issue with the platform view mode Android picks by
  // default. This is the officially documented workaround from the
  // google_maps_flutter_android package.
  if (Platform.isAndroid) {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Urban Services App',
          theme: theme,
          routerConfig: router,
          scaffoldMessengerKey: scaffoldMessengerKey,
          // Wraps every screen so any of them can use Showcase/
          // ShowCaseWidget.of(context) — e.g. the "complete your profile"
          // spotlight on the Home screen's avatar.
          builder: (context, child) => ShowCaseWidget(
            builder: (context) => child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
