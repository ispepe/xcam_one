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
  ThemeState() : _userDarkMode = SpUtil.getString(Constant.theme);

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

  /// 切换指定色彩
  /// 没有传[brightness]就不改变brightness,color同理
  void switchTheme({required String userDarkMode}) {
    _userDarkMode = userDarkMode;

    notifyListeners();

    /// 存储当前设置
    saveTheme2Storage(_userDarkMode);
  }

  /// 根据主题 明暗 和 颜色 生成对应的主题
  /// [dark]系统的Dark Mode
  ThemeData themeData({bool isDarkMode = false}) {
    return ThemeData(
      fontFamily: 'PingFangSC',
      errorColor: isDarkMode ? Colours.darkErrorColor : Colours.errorColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,

      primaryColor: isDarkMode ? Colours.darkAppMain : Colours.appMain,
      accentColor: isDarkMode ? Colours.darkAccentColor : Colours.accentColor,
      // Tab指示器颜色
      indicatorColor: isDarkMode ? Colours.darkAppMain : Colours.appMain,
      // primaryColorDark: themeColor[800],
      // primaryColorLight: themeColor[400],
      textSelectionTheme: TextSelectionThemeData(
        // 文字选择色（输入框复制粘贴菜单）
        selectionColor: isDarkMode ? Colours.darkAppMain : Colours.appMain,
        // selectionHandleColor: Colours.appMain,
        cursorColor: isDarkMode ? Colours.darkAccentColor : Colours.accentColor,
      ),
      buttonColor: isDarkMode ? Colours.darkButtonColor : Colours.buttonColor,
      // 页面背景色
      scaffoldBackgroundColor: isDarkMode ? Colours.darkBgColor : Colors.white,
      // 主要用于Material背景色
      canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
      textTheme: TextTheme(
          // TextField输入文字颜色
          // subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
          // Text文字样式
          // bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,
          ),
      inputDecorationTheme: InputDecorationTheme(
        // hintStyle:
        //     isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 0.7, color: Colours.appMain)),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        color: isDarkMode ? Colours.darkBgColor : Colors.white,
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
        primaryColor: isDarkMode ? Colours.darkAppMain : Colours.appMain,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: isDarkMode
            ? Colours.darkSelectedItemColor
            : Colours.selectedItemColor,
        unselectedItemColor: isDarkMode
            ? Colours.darkUnselectedItemColor
            : Colours.unselectedItemColor,

        /// TODO: 3/29/21 待测试区别
        type: BottomNavigationBarType.fixed,
      ),
      // hintColor: themeData.hintColor.withAlpha(90),
      toggleableActiveColor:
          isDarkMode ? Colours.darkAccentColor : Colours.accentColor,
      // chipTheme: themeData.chipTheme.copyWith(
      //   pressElevation: 0,
      //   padding: EdgeInsets.symmetric(horizontal: 10),
      //   labelStyle: themeData.textTheme.caption,
      //   backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      // ),
    );
  }

  /// 数据持久化到shared preferences
  void saveTheme2Storage(String? themeMode) async {
    await SpUtil.putString(Constant.theme, themeMode!)
        ?.then((value) => debugPrint('主题明暗模式存储状态：$themeMode'));
  }
}
