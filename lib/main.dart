import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/themes/theme.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/routes/route_pages.dart';
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

  // Initialize SharedPreferences
  await SharedPreferencesHelper.init();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Urban Services App',
          theme: theme,
          // builder: EasyLoading.init(),
          getPages: getRoutes(),
          initialRoute: RouteNames.splashScreen,
        );
      },
    );
  }
}
