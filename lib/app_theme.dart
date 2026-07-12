import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme extends ChangeNotifier {
  static const _keyBg = 'theme_bg';
  static const _keyCardBack = 'theme_card_back';

  static const int _defaultBgValue = 0xFFDCF0FB;
  static const int _defaultCardBackValue = 0xFF3853A4;

  static const int _highlightValue = 0xFFFFC107;

  Color backgroundColor;
  Color cardBackColor;

  AppTheme({
    this.backgroundColor = const Color(_defaultBgValue),
    this.cardBackColor = const Color(_defaultCardBackValue),
  });

  Color get highlightColor => const Color(_highlightValue);
  Color get crosshatchColor => Color.lerp(backgroundColor, Colors.black, 0.12)!;
  Color get highlightBorderColor => Color.lerp(highlightColor, Colors.black, 0.18)!;

  static Future<AppTheme> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppTheme(
      // ignore: deprecated_member_use
      backgroundColor: Color(prefs.getInt(_keyBg) ?? _defaultBgValue),
      // ignore: deprecated_member_use
      cardBackColor: Color(prefs.getInt(_keyCardBack) ?? _defaultCardBackValue),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: deprecated_member_use
    await prefs.setInt(_keyBg, backgroundColor.value);
    // ignore: deprecated_member_use
    await prefs.setInt(_keyCardBack, cardBackColor.value);
  }

  void setBackgroundColor(Color c) {
    backgroundColor = c;
    notifyListeners();
    _save();
  }

  void setCardBackColor(Color c) {
    cardBackColor = c;
    notifyListeners();
    _save();
  }

  void reset() {
    backgroundColor = const Color(_defaultBgValue);
    cardBackColor = const Color(_defaultCardBackValue);
    notifyListeners();
    _save();
  }
}

class AppThemeScope extends InheritedNotifier<AppTheme> {
  const AppThemeScope({
    super.key,
    required AppTheme theme,
    required super.child,
  }) : super(notifier: theme);

  static AppTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppThemeScope>()!.notifier!;
}
