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

import 'pages/welcome_page.dart';

class WelcomeRouter implements IRouterProvider {
  static String welcomePage = '/welcome';

  @override
  void initRouter(FluroRouter router) {
    router.define(welcomePage,
        handler: Handler(handlerFunc: (_, __) => WelcomePage()));
  }
}
