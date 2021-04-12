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
import 'package:xcam_one/routers/router_init.dart';

class PhotoViewRouter implements IRouterProvider {
  static String photoView = '/photoView';

  @override
  void initRouter(FluroRouter router) {
    router.define(photoView, handler: Handler(handlerFunc: (_, params) {
      final type = params['type']?.first ?? 'photo';
      if (type == 'photo') {
        return PhotoViewPage(
            currentIndex: int.parse(params['currentIndex']?.first ?? '0'));
      } else {
        return CameraViewPage(
            currentIndex: int.parse(params['currentIndex']?.first ?? '0'));
      }
    }));
  }
}
