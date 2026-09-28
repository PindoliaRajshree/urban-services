import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_services/features/authentication/forgot_password/check_email_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => const MaterialApp(home: CheckEmailScreen()),
        ),
      ),
    );
    await tester.pump();
  }

  List<String> boxValues(WidgetTester tester) => tester
      .widgetList<TextField>(find.byType(TextField))
      .map((f) => f.controller!.text)
      .toList();

  testWidgets('pasting a whole code fills every OTP box', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, '1234');
    await tester.pump();

    expect(boxValues(tester), ['1', '2', '3', '4']);
  });

  testWidgets('typing one digit per box still works', (tester) async {
    await pumpScreen(tester);

    final boxes = find.byType(TextField);
    await tester.enterText(boxes.at(0), '5');
    await tester.enterText(boxes.at(1), '6');
    await tester.pump();

    expect(boxValues(tester), ['5', '6', '', '']);
  });
}
