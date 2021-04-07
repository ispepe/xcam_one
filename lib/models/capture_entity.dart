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

class CaptureEntity with JsonConvert<CaptureEntity> {
  @JSONField(name: "Function")
  CaptureFunction? function;
}

class CaptureFunction with JsonConvert<CaptureFunction> {
  @JSONField(name: "Cmd")
  String? cmd;
  @JSONField(name: "Status")
  String? status;
  @JSONField(name: "File")
  CaptureFunctionFile? file;
  @JSONField(name: "FREEPICNUM")
  String? freePicNum;
}

class CaptureFunctionFile with JsonConvert<CaptureFunctionFile> {
  @JSONField(name: "NAME")
  String? name;
  @JSONField(name: "FPATH")
  String? fPath;
}
