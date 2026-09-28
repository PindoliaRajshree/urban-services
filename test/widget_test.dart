import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_services/core/session/token_store.dart';
import 'package:urban_services/features/authentication/splash/welcome_screen.dart';
import 'package:urban_services/main.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

void main() {
  testWidgets('logged-out launch goes splash -> Welcome', (tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    await TokenStore.init();

    // Phone-sized surface (the app is designed for 375x812).
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // The test font (Ahem) draws every glyph as a full square, so text is
    // far wider than with Inter and the Welcome buttons overflow. Ignore
    // only overflow errors; anything else (routing, providers) still fails.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.byType(WelcomeScreen), findsNothing);

    // Splash waits 3s before routing.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Continue as User'), findsOneWidget);
    expect(find.text('Continue as Provider'), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}
