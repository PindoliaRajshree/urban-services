import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/features/home_main/main_navigation_controller.dart';
import 'package:urban_services/features/profile/profile_screen.dart';
import 'package:urban_services/widgets/custom_bottom_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final controller = Get.put(MainNavigationController());

  final List<Widget> _screens = [
    const Center(child: Text('Services')),
    const Center(child: Text('Booking')),
    const Center(child: Text('Home')),
    const Center(child: Text('Chat')),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Screen Content
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Obx(() => _screens[controller.currentIndex.value]),
              ),
            ),
            
            // Custom Bottom Bar with Sharp Semi-Circular Notch
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomBar(),
            ),
        
            // Home Button sitting inside the Semi-Circular Notch with a gap
            Positioned(
              bottom: 30, // Centered vertically relative to the 50px deep notch
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.changeIndex(2),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.home,
                          width: 26,
                          height: 26,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Home',
                          style: customTextStyle(
                            10,
                            AppColors.white,
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
