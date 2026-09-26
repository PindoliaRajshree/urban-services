// File: lib/features/home_main/home_main.dart
// Purpose: Main entry point screen after login/registration, featuring the primary navigation structure.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/core/session/user_role.dart';
import 'package:urban_services/features/chat/chat_list_screen.dart';
import 'package:urban_services/features/home_main/main_navigation_provider.dart';
import 'package:urban_services/features/home/home_screen.dart';
import 'package:urban_services/features/home_provider/provider_home_screen.dart';
import 'package:urban_services/features/my_bookings/my_bookings_screen.dart';
import 'package:urban_services/features/profile/profile_screen.dart';
import 'package:urban_services/widgets/custom_bottom_bar.dart';

class HomeMain extends ConsumerWidget {
  const HomeMain({super.key});

  /// Returns the appropriate list of screens based on the current user role
  List<Widget> _getScreens(UserRole role) {
    return [
      const Center(child: Text('Services')),
      const MyBookingsScreen(),
      // Dynamically load the dashboard based on role
      role.isProvider ? const ProviderHomeScreen() : const HomeScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionProvider.select((s) => s.effectiveRole));
    final currentIndex = ref.watch(mainTabIndexProvider);
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Android back from any other tab returns to Home first; back from Home
    // exits the app.
    return PopScope(
      canPop: currentIndex == MainTabIndexNotifier.homeIndex,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref
            .read(mainTabIndexProvider.notifier)
            .changeIndex(MainTabIndexNotifier.homeIndex);
      },
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        resizeToAvoidBottomInset:
            false, // Prevents resizing which could break bottom bar
        body: SafeArea(
          child: Stack(
            children: [
              // Current Screen Content based on selection
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: _getScreens(role)[currentIndex],
                ),
              ),

              // Standardized Custom Bottom Bar with integrated floating button
              if (!isKeyboardVisible)
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomBottomBar(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
