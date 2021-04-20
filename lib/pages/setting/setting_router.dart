/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'dart:convert' as convert;

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:xcam_one/pages/photo_view/pages/camera_view_page.dart';
import 'package:xcam_one/pages/photo_view/pages/photo_view_page.dart';
import 'package:xcam_one/pages/setting/pages/app_version_page.dart';
import 'package:xcam_one/pages/setting/pages/camera_storage_page.dart';
import 'package:xcam_one/pages/setting/pages/notice_page.dart';
import 'package:xcam_one/routers/router_init.dart';

class SettingRouter implements IRouterProvider {
  static String cameraStorage = '/cameraStorage';
  static String sysNotice = '/sysNotice';
  static String appVersion = '/appVersion';

  @override
  void initRouter(FluroRouter router) {
    router.define(cameraStorage, handler: Handler(handlerFunc: (_, params) {
      return CameraStoragePage();
    }));

    router.define(sysNotice, handler: Handler(handlerFunc: (_, params) {
      return NoticePage();
    }));

    router.define(appVersion, handler: Handler(handlerFunc: (_, params) {
      return AppVersionPage();
    }));
  }
}
