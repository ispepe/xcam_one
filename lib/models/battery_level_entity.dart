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

enum BatteryStatus {
  batteryFull,
  batteryMed,
  batteryLow,
  batteryEmpty, // 电量空
  batteryExhausted, // 没电
  batteryCharge, // 充电
  batteryStatusTotalNum
}

extension BatteryStatusEx on BatteryStatus {
  String get value => [
        'batteryFull',
        'batteryMed',
        'batteryLow',
        'batteryEmpty',
        'batteryExhausted',
        'batteryCharge',
        'batteryStatusTotalNum'
      ][index];
}

class BatteryLevelEntity with JsonConvert<BatteryLevelEntity> {
  @JSONField(name: "Function")
  BatteryLevelFunction? function;
}

class BatteryLevelFunction with JsonConvert<BatteryLevelFunction> {
  @JSONField(name: "Cmd")
  int? cmd;
  @JSONField(name: "Status")
  int? status;
  @JSONField(name: "Value")
  int? batteryStatus;
}
