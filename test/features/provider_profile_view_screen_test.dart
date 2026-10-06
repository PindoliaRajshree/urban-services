import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/sub_service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/provider_profile_view_screen.dart';
import 'package:urban_services/features/home_provider/complete_profile/service_type_provider.dart';
import 'package:urban_services/routes/route_args.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/profile_avatar.dart';

void main() {
  group('maskTail', () {
    test('keeps only the last 4 characters', () {
      expect(maskTail('123456789012'), '•••• 9012');
      expect(maskTail('1234 5678 9012'), '•••• 9012');
      expect(maskTail('ABCDE1234F'), '•••• 234F');
    });

    test('short or empty values', () {
      expect(maskTail('123'), '123');
      expect(maskTail(null), '');
      expect(maskTail('  '), '');
    });
  });

  group('ProviderProfileViewScreen', () {
    final profile = ProviderProfile(
      name: 'Asha',
      email: 'asha@example.com',
      mobileNumber: '9876543210',
      gender: 'female',
      dateOfBirth: DateTime(1995, 2, 1),
      serviceTypeId: 1,
      subServiceTypeId: 2,
      experienceYears: 6,
      pricingType: 'per_hour',
      startingPrice: '500',
      availabilityType: 'full_time',
      serviceAreaKm: 10,
      teamSize: 3,
      city: 'Indore',
      state: 'MP',
      aadhaarNumber: '123456789012',
      panNumber: 'ABCDE1234F',
      accountNumber: '000123454321',
      ifscCode: 'sbin0001234',
      isProfileCompleted: true,
    );

    /// Pumps the screen under a router that records the wizard's args.
    Future<List<int>> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final openedSteps = <int>[];
      final router = GoRouter(
        initialLocation: RouteNames.providerProfileView,
        routes: [
          GoRoute(
            path: RouteNames.providerProfileView,
            builder: (_, _) => const ProviderProfileViewScreen(),
          ),
          GoRoute(
            path: RouteNames.completeProviderProfile,
            builder: (_, state) {
              openedSteps.add(
                (state.extra as ProviderProfileEditArgs).initialStep,
              );
              return const SizedBox();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            providerProfileStatusProvider.overrideWith((_) async => profile),
            serviceTypesProvider.overrideWith(
              (_) async => [ServiceType(id: 1, name: 'Plumbing')],
            ),
            subServiceTypesProvider.overrideWith(
              (_, _) async => [
                SubServiceType(id: 2, serviceTypeId: 1, name: 'Tap repair'),
              ],
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, _) => MaterialApp.router(routerConfig: router),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return openedSteps;
    }

    testWidgets('shows saved details with sensitive numbers masked', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Asha'), findsOneWidget);
      expect(find.text('Profile completed'), findsOneWidget);
      expect(find.text('Plumbing'), findsWidgets);

      // The list builds lazily: scroll each row into view, top to bottom.
      for (final text in [
        'Female',
        '01/02/1995',
        'Documents',
        '•••• 9012', // Aadhaar
        '•••• 234F', // PAN
        'Tap repair',
        '5+ years',
        '₹500 per hour',
        'Service Area',
        'Indore, MP',
        '10 km',
        '•••• 4321', // account
        'SBIN0001234',
      ]) {
        await tester.scrollUntilVisible(find.text(text), 100);
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.text('123456789012'), findsNothing);
      expect(find.text('000123454321'), findsNothing);
    });

    testWidgets('Edit opens the wizard on that section\'s page', (
      tester,
    ) async {
      final openedSteps = await pump(tester);

      // One section (and Edit) per wizard page.
      for (final (i, section) in [
        'Basic Information',
        'Service Details',
        'Bank Details',
      ].indexed) {
        await tester.scrollUntilVisible(find.text(section), 100);
        final edit = find.descendant(
          of: find
              .ancestor(of: find.text(section), matching: find.byType(Row))
              .last,
          matching: find.text('Edit'),
        );
        await tester.tap(edit);
        await tester.pumpAndSettle();
        expect(openedSteps.last, i, reason: section);
        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
      }
      expect(openedSteps, [0, 1, 2]);
    });
  });

  group('providerProfileRoute', () {
    test('opens the view only for a completed profile', () {
      expect(providerProfileRoute(null), RouteNames.completeProviderProfile);
      expect(
        providerProfileRoute(ProviderProfile()),
        RouteNames.completeProviderProfile,
      );
      expect(
        providerProfileRoute(ProviderProfile(isProfileCompleted: true)),
        RouteNames.providerProfileView,
      );
    });
  });

  testWidgets('ProfileAvatar shows a person icon without a photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProfileAvatar(width: 60, height: 60)),
    );
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
  });
}
