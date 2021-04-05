/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'package:xcam_one/generated/json/base/json_convert_content.dart';
import 'package:xcam_one/global/constants.dart';

class BaseEntity<T> {
  BaseEntity(this.code, this.message, this.data);

  BaseEntity.fromJson(Map<String, dynamic>? map) {
    if (map != null) fromJson(map);
  }

  BaseEntity fromJson(Map<String, dynamic> json) {
    code = json[Constant.code] as int;
    message = json[Constant.message] as String;
    if (json.containsKey(Constant.data)) {
      data = _generateOBJ<T>(json[Constant.data]);
    }
    return this;
  }

  int? code;
  String? message;
  T? data;

  T _generateOBJ<O>(Object json) {
    if (T.toString() == 'String') {
      // ignore: avoid_as
      return json.toString() as T;
    } else if (T.toString() == 'Map<dynamic, dynamic>') {
      // ignore: avoid_as
      return json as T;
    } else {
      /// List类型数据由fromJsonAsT判断处理
      return JsonConvert.fromJsonAsT<T>(json);
    }
  }
}
