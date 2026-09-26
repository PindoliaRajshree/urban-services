import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active bottom-bar tab of HomeMain. Defaults to Home (center).
class MainTabIndexNotifier extends Notifier<int> {
  static const int homeIndex = 2;

  @override
  int build() => homeIndex;

  void changeIndex(int index) => state = index;
}

final mainTabIndexProvider =
    NotifierProvider.autoDispose<MainTabIndexNotifier, int>(
      MainTabIndexNotifier.new,
    );
