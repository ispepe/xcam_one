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

import 'package:flustars/flustars.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';

import 'package:xcam_one/global/constants.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';

enum EConfig {
  baseUrl, // 后台服务路径
  defaultAvatar, // 默认头像
  protocolUrl, // 协议地址
}

// 全局类
class GlobalStore {
  static bool _isDebug = true;

  /// 第一次需要显示引导操作
  static bool first = true;

  /// 临时目录 eg: cookie
  static Directory? temporaryDirectory;

  /// 初始化必备操作 eg:user数据
  static LocalStorage? localStorage;

  /// 所有获取配置的唯一入口
  static Map<EConfig, String> config = {};

  /// 缩略图OSS URL
  static final String thumbsUrl = "https://cdn.jing-pei.cn/avatar/";

  /// 临时目录
  static String? tempPath;

  /// 程序文档目录
  static String? applicationPath;

  /// 移除所有监听
  static void removeListener() {}

  /// 心跳检测开关 只有当前链接断开才进入心跳检测
  static bool startHeartbeat = true;

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

    first = SpUtil.getBool(SharedPreferencesKeys.showWelcome, defValue: true) ??
        true;
    if (first) {
      await SpUtil.putBool(SharedPreferencesKeys.showWelcome, false);
    }

    /// TODO: 3/29/21 待处理 此处配置相机连接信息
    if (_isDebug) {
      config = {
        EConfig.baseUrl: 'http://192.168.1.254/',
        // ECON.protocolUrl: 'https://www.baidu.com',
      };
    } else {
      config = {
        EConfig.baseUrl: 'http://192.168.1.254/',
        // ECON.protocolUrl: 'https://www.baidu.com',
      };
    }

    await Future.delayed(Duration(seconds: 2));
  }

  static VlcPlayerController? videoPlayerController;

  /// TODO: 4/16/21 待处理 临时赋予一个Movie的值
  static WifiAppMode wifiAppMode = WifiAppMode.wifiAppModeMovie;
}
