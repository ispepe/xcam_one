/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:xcam_one/generated/json/base/json_convert_content.dart';
import 'package:xcam_one/generated/json/base/json_field.dart';

class SsidPassEntity with JsonConvert<SsidPassEntity> {
  @JSONField(name: "LIST")
  SsidPassLIST? xLIST;
}

class SsidPassLIST with JsonConvert<SsidPassLIST> {
  @JSONField(name: "SSID")
  String? sSID;
  @JSONField(name: "PASSPHRASE")
  String? pASSPHRASE;
}
