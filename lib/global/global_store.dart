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
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:xcam_one/global/constants.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_provider.dart';

enum ECON {
  baseUrl, // 后台服务路径
  defaultAvatar, // 默认头像
  protocolUrl, // 协议地址
}

// 全局类
class GlobalStore {
  static bool _isDebug = true;

  // /// TODO: 3/28/21  第一次需要显示引导操作
  static bool first = true;

  /// 临时目录 eg: cookie
  static Directory? temporaryDirectory;

  /// 初始化必备操作 eg:user数据
  static LocalStorage? localStorage;

  /// 所有获取配置的唯一入口
  static Map<ECON, String> config = {};

  /// 缩略图OSS URL
  static final String thumbsUrl = "https://cdn.jing-pei.cn/avatar/";

  /// 移除所有监听
  static void removeListener() {}

  static Future<void> init(bool isDebug) async {
    _isDebug = isDebug;

    /// sp初始化
    await SpUtil.getInstance();

    if (!kIsWeb) {
      temporaryDirectory = await getTemporaryDirectory();

      if (Platform.isAndroid || Platform.isIOS) {}
    }

    /// /// NOTE: 3/29/21 可以进行json字符的存储
    localStorage = LocalStorage('LocalStorage');
    await localStorage!.ready;

    first = SpUtil.getBool(SharedPreferencesKeys.showWelcome) ?? true;
    if (first) {
      await SpUtil.putBool(SharedPreferencesKeys.showWelcome, false);
    }

    /// TODO: 3/29/21 待处理 此处配置相机连接信息
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

    await Future.delayed(Duration(seconds: 2));
  }

  static VlcPlayerController? videoPlayerController;

  final provider = PhotoProvider();
}
