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

class CmdStatusEntity with JsonConvert<CmdStatusEntity> {
  @JSONField(name: "Function")
  CmdStatusFunction? function;
}

class CmdStatusFunction with JsonConvert<CmdStatusFunction> {
  @JSONField(name: "Cmd")
  int? cmd;
  @JSONField(name: "Status")
  int? status;
}
