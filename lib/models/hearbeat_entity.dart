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

class HearbeatEntity with JsonConvert<HearbeatEntity> {
  @JSONField(name: "Function")
  HearbeatFunction? function;
}

class HearbeatFunction with JsonConvert<HearbeatFunction> {
  @JSONField(name: "Cmd")
  String? cmd;
  @JSONField(name: "Status")
  String? status;
}
