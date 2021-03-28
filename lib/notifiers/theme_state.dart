/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:xcam_one/global/constants.dart';
import 'package:xcam_one/res/colors.dart';
import 'package:xcam_one/res/resources.dart';

extension ThemeModeExtension on ThemeMode {
  String get value => ['System', 'Light', 'Dark'][index];
}

// ignore: public_member_api_docs
class ThemeState with ChangeNotifier {
  // ignore: public_member_api_docs
  ThemeState()
      : _themeColor = Colors.primaries[SpUtil.getInt(kThemeColorIndex) ?? 5],
        _fontIndex = SpUtil.getInt(kFontIndex) ?? 0,
        _userDarkMode = SpUtil.getString(Constant.theme);

  ///主题颜色 key值
  static const kThemeColorIndex = 'kThemeColorIndex';

  ///字体 key值
  static const kFontIndex = 'kFontIndex';

  ///字体种类
  static const fontValueList = ['system', 'kuaile'];

  /// 当前主题颜色
  MaterialColor _themeColor;

  /// 当前字体索引
  int _fontIndex;

  /// 用户选择的明暗模式
  String? _userDarkMode;

  /// 决定了系统的明暗模式
  ThemeMode getThemeMode() {
    switch (_userDarkMode) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  /// 同步主题
//  void syncTheme() {
//    _userDarkMode = SpUtil.getString(Constant.theme);
//    if (_userDarkMode.isNotEmpty && _userDarkMode != ThemeMode.system.value) {
//      notifyListeners();
//    }
//  }

  int get fontIndex => _fontIndex;

  /// 切换指定色彩
  /// 没有传[brightness]就不改变brightness,color同理
  void switchTheme({required String userDarkMode}) {
    _userDarkMode = userDarkMode ?? _userDarkMode;

    notifyListeners();

    /// 存储当前设置
    saveTheme2Storage(_userDarkMode, _themeColor);
  }

  /// 切换字体
  void switchFont(int index) {
    _fontIndex = index;
    saveFontIndex(index);
  }

  /// 根据主题 明暗 和 颜色 生成对应的主题
  /// [dark]系统的Dark Mode
  ThemeData themeData({bool isDarkMode = false}) {
    final themeColor = _themeColor;
    final accentColor = isDarkMode ? themeColor[700] : _themeColor;

    final textSelectionTheme = TextSelectionThemeData(
      // 文字选择色（输入框复制粘贴菜单）
      selectionColor: themeColor.withAlpha(70),
      selectionHandleColor: themeColor,
      cursorColor: accentColor,
    );

    final bottomNavigationBarTheme = BottomNavigationBarThemeData(
      selectedItemColor: themeColor,
      // unselectedItemColor: themeData.textTheme.caption.color.withAlpha(90),
      // type: BottomNavigationBarType.fixed,
    );

    /// 设置全局input样式
    final width = 0.5;
    final inputDecorationTheme = InputDecorationTheme(
      hintStyle: TextStyle(fontSize: 14),
      // errorBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(width: width, color: errorColor)),
      // focusedErrorBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(width: 0.7, color: errorColor)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: themeColor)),
      // enabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(width: width, color: dividerColor)),
      // border: UnderlineInputBorder(
      //     borderSide: BorderSide(width: width, color: dividerColor)),
      // disabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(width: width, color: disabledColor)),
    );

    var themeData = ThemeData(
      fontFamily: fontValueList[fontIndex],
      errorColor: isDarkMode ? Colours.dark_red : Colours.red,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
//        primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
//        accentColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      // Tab指示器颜色
//        indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      primaryColor: themeColor,
      primaryColorDark: themeColor[800],
      primaryColorLight: themeColor[400],
      accentColor: accentColor,
      indicatorColor: accentColor,
      textSelectionTheme: textSelectionTheme,
      buttonColor:
          isDarkMode ? Colours.dark_button_color : Colours.button_color,
      // 页面背景色
      scaffoldBackgroundColor:
          isDarkMode ? Colours.dark_bg_color : Colors.white,
      // 主要用于Material背景色
      canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
      textTheme: TextTheme(
        // TextField输入文字颜色
        subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
        // Text文字样式
        bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,
        subtitle2:
            isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        color: isDarkMode ? Colours.dark_bg_color : Colors.white,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        actionsIconTheme: IconThemeData(
          color: isDarkMode ? Colours.dark_text : Colours.text,
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colours.dark_text : Colours.text,
        ),
      ),
      dividerTheme: DividerThemeData(
          color: isDarkMode ? Colours.dark_line : Colours.line,
          space: 0.6,
          thickness: 0.6),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      bottomNavigationBarTheme: bottomNavigationBarTheme,
    );

    /// TODO: 1/17/21 待处理 合并，原是获取系统自带系统样式
    themeData = themeData.copyWith(
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: themeColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      bottomNavigationBarTheme: themeData.bottomNavigationBarTheme.copyWith(
        selectedItemColor: themeColor,
        unselectedItemColor: themeData.textTheme.caption!.color!.withAlpha(90),
        type: BottomNavigationBarType.fixed,
      ),
      splashColor: themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      toggleableActiveColor: accentColor,
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      ),
      inputDecorationTheme: inputDecorationTheme,
    );

    return themeData;
  }

  /// 字体选择持久化
  static void saveFontIndex(int index) async {
    await SpUtil.putInt(kFontIndex, index);
  }

  /// 数据持久化到shared preferences
  void saveTheme2Storage(String? themeMode, MaterialColor themeColor) async {
    final index = Colors.primaries.indexOf(themeColor);

    await SpUtil.putString(Constant.theme, themeMode!)
        ?.then((value) => debugPrint('主题明暗模式存储状态：$themeMode'));

    await SpUtil.putInt(kThemeColorIndex, index)
        ?.then((value) => debugPrint('主题颜色存储状态：$themeColor'));
  }
}
