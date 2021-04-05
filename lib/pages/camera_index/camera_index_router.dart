/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'package:fluro/fluro.dart';
import 'package:xcam_one/routers/router_init.dart';

import 'pages/camera_index_page.dart';

class CameraIndexRouter implements IRouterProvider {
  static String cameraIndexPage = '/cameraIndex';

  @override
  void initRouter(FluroRouter router) {
    router.define(cameraIndexPage,
        handler: Handler(handlerFunc: (_, __) => CameraIndexPage()));
  }
}
