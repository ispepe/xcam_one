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

class IQInfoEntity with JsonConvert<IQInfoEntity> {
  @JSONField(name: "Function")
  IQInfoFunction? function;
}

class IQInfoFunction with JsonConvert<IQInfoFunction> {
  @JSONField(name: "Shdr")
  int? shdr;
  @JSONField(name: "Wdr")
  int? wdr;
  @JSONField(name: "Ev")
  int? ev;
  @JSONField(name: "Sharpness")
  int? sharpness;
  @JSONField(name: "Saturation")
  int? saturation;
  @JSONField(name: "Iso")
  int? iso;
  @JSONField(name: "Status")
  int? status;
}
