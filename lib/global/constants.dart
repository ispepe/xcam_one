/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flutter/foundation.dart';

/// 最大长度
const int phoneMaxLength = 11;
const int passwordMaxLength = 32;
const int nicknameMaxLength = 32;

/// 如果key是全局，则存到这里
class SharedPreferencesKeys {
  /// boolean
  /// 用于欢迎页面. 只有第一次访问才会显示. 或者手动将这个值设为false
  static String showWelcome = 'loginWelcone';

  /// json
  /// 用于存放搜索页的搜索数据.
  /// [{
  ///  name: 'name'
  ///
  /// }]
  static String searchHistory = 'searchHistory';

  static String tokenKey = 'token';

  /// TODO: 4/23/21  存储延迟拍摄时间

}

class Constant {
  /// debug开关，上线需要关闭
  /// App运行在Release环境时，inProduction为true；当App运行在Debug和Profile环境时，inProduction为false
  static const bool inProduction = kReleaseMode;

  static bool isDriverTest = false;
  static bool isUnitTest = false;

  static const String data = 'data';
  static const String message = 'message';
  static const String code = 'code';

  static const String keyGuide = 'keyGuide';
  static const String phone = 'phone';
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';

  static const String theme = 'AppTheme';

  static const String FWString = 'xCam_0729_005';
}
