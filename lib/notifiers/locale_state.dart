/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:xcam_one/generated/l10n.dart';

class LocaleState extends ChangeNotifier {
  LocaleState() {
    _localeIndex = SpUtil.getInt(kLocaleIndex) ?? 0;
  }

  ///配置语言语种
  static const localeValueList = ['', 'zh-CN', 'en-US'];

  ///本地语言选择的 key值
  static const kLocaleIndex = 'kLocaleIndex';

  int _localeIndex = 0;

  int get localeIndex => _localeIndex;

  Locale? get locale {
    if (_localeIndex > 0) {
      final value = localeValueList[_localeIndex!].split('-');
      return Locale(value[0], value.length == 2 ? value[1] : '');
    }
    // 跟随系统
    return null;
  }

  void switchLocale(int index) {
    _localeIndex = index;
    notifyListeners();
    SpUtil.putInt(kLocaleIndex, index);
  }

  static String localeName(index, context) {
    switch (index) {
      case 0:
        return S.of(context).autoBySystem;
      case 1:
        return '中文';
      case 2:
        return 'English';
      default:
        return '';
    }
  }
}
