/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flustars/flustars.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:xcam_one/global/constants.dart';
import 'package:xcam_one/notifiers/global_state.dart';

enum ECON {
  baseUrl, // 后台服务路径
  defaultAvatar, // 默认头像
  protocolUrl, // 协议地址
}

// 全局类
class GlobalStore {
  static bool _isDebug = true;

  // /// TODO: 3/28/21  第一次需要显示引导操作
  static bool _first = true;

  /// 临时目录 eg: cookie
  static Directory? temporaryDirectory;

  /// 初始化必备操作 eg:user数据
  static LocalStorage? localStorage;

  /// 所有获取配置的唯一入口
  static Map<ECON, String> config = {};

  static String? token;

  /// 缩略图OSS URL
  static final String thumbsUrl = "https://cdn.jing-pei.cn/avatar/";

  /// 移除所有监听
  static void removeListener() {}

  static init(bool isDebug) async {
    _isDebug = isDebug;

    if (!kIsWeb) {
      temporaryDirectory = await getTemporaryDirectory();

      if (Platform.isAndroid || Platform.isIOS) {}
    }

    localStorage = LocalStorage('LocalStorage');
    await localStorage!.ready;

    // TODO：获取默认token，登录后需要进行Token的存储
    token = SpUtil.getString(SharedPreferencesKeys.tokenKey);

    /// TODO: 生产与测试分开
    if (_isDebug) {
      config = {
        ECON.baseUrl: 'http://127.0.0.1:8181/api/',
        ECON.defaultAvatar:
            thumbsUrl + 'test2.jpg?x-oss-process=style/same_mito',
        ECON.protocolUrl: 'https://www.baidu.com',
      };
    } else {
      config = {
        ECON.baseUrl: 'http://127.0.0.1:8181/api/',
        ECON.defaultAvatar:
            thumbsUrl + 'test1.jpg?x-oss-process=style/same_mito',
        ECON.protocolUrl: 'https://www.baidu.com',
      };
    }
  }

  static initWidget(BuildContext context) {
    if (_first) {
      _first = false;
    }

    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {}
    }
  }
}
