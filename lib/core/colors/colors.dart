// File: lib/core/colors/colors.dart
// Purpose: Defines the application's color palette and gradients.

import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color.fromRGBO(37, 99, 235, 1);
  static const Color primaryLight = Color.fromRGBO(96, 165, 250, 1);
  static const Color accent = Color.fromRGBO(6, 182, 212, 1);
  static const Color primaryDark = Color.fromRGBO(17, 54, 137, 1);
  static const LinearGradient gradient = LinearGradient(
    colors: [Color.fromRGBO(17, 54, 137, 1), Color.fromRGBO(20, 103, 206, 1)],
  );

  // Neutral Colors
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color text = Color.fromRGBO(64, 64, 64, 1);
  static const Color darkGrey = Color.fromRGBO(109, 109, 109, 1);
  static const Color darkGrey2 = Color.fromRGBO(75, 75, 75, 1);
  static const Color grey = Color.fromRGBO(160, 162, 166, 1);
  static const Color lightGrey2 = Color.fromRGBO(217, 217, 217, 1);
  static const Color headingGrey = Color.fromRGBO(83, 83, 83, 1);
  static const Color darkBlack = Color.fromRGBO(38, 38, 38, 1);
  static const Color grey3 = Color.fromRGBO(42, 42, 42, 1);
  static const Color lightGrey3 = Color.fromRGBO(236, 236, 236, 1);
  static const Color lightGrey = Color.fromRGBO(226, 232, 240, 1);

  // Semantic Colors (Status)
  static const Color success = Color.fromRGBO(0, 146, 82, 1);
  static const Color warning = Color.fromRGBO(255, 168, 0, 1);
  static const Color info = Color.fromRGBO(0, 201, 243, 1);
  static const Color danger = Color.fromRGBO(232, 0, 63, 1);
  static const Color primaryOrange = Color.fromRGBO(245, 158, 11, 1);
  static const Color cardWhite = Color.fromRGBO(252, 253, 255, 1);
  static const Color lightSuccess = Color.fromRGBO(212, 255, 187, 1);

  // Solid toast/snackbar colors — sampled directly from the reference
  // design (the green "success" toast) and hue-rotated at the same
  // saturation/lightness for the other toast types, so all four read as
  // one consistent family.
  static const Color toastSuccess = Color.fromRGBO(72, 174, 108, 1);
  static const Color toastDanger = Color.fromRGBO(174, 77, 72, 1);
  static const Color toastWarning = Color.fromRGBO(174, 137, 72, 1);
  static const Color toastInfo = Color.fromRGBO(72, 132, 174, 1);
  static const Color successGreen = Color.fromRGBO(1, 128, 20, 1);
  static const Color uploadBg = Color.fromRGBO(255, 253, 253, 1);
  static const Color darkBlueText = Color.fromRGBO(31, 41, 55, 1);
  static const Color greyText = Color.fromRGBO(107, 114, 128, 1);
  static const Color lightGreyBorder = Color.fromRGBO(209, 213, 219, 1);

  // UI Colors
  static const Color background = Color.fromRGBO(222, 241, 255, 1);
  static const Color screenBackground = Color.fromRGBO(233, 242, 253, 1);

  // Chat Screen Colors
  static const Color chatAvatarBg = Color.fromRGBO(237, 238, 240, 1);
  static const Color onlineStatus = Color.fromRGBO(15, 225, 109, 1);
  static const Color chatNameText = Color.fromRGBO(0, 14, 8, 1);
  static const Color chatSubText = Color.fromRGBO(121, 124, 123, 1);
  static const Color unreadBadge = Color.fromRGBO(240, 74, 76, 1);

  // Chat Conversation Screen Colors
  static const Color receiverBubble = Color.fromRGBO(16, 54, 137, 1);
  static const Color dateChipBg = Color.fromRGBO(248, 251, 250, 1);
  static const Color chatInputBorder = Color.fromRGBO(238, 250, 248, 1);
  static const Color chatInputBg = Color.fromRGBO(243, 246, 246, 1);
}
