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

class CameraFileListEntity with JsonConvert<CameraFileListEntity> {
  @JSONField(name: "LIST")
  CameraFileList? list;
}

class CameraFileList with JsonConvert<CameraFileList> {
  @JSONField(name: "ALLFile")
  List<CameraFile>? allFile;

  @override
  CameraFileList fromJson(Map<String, dynamic> json) {
    if (json['ALLFile'] != null) {
      if (json['ALLFile'] is List) {
        allFile = (json['ALLFile'] as List)
            .map((v) => CameraFile().fromJson(v))
            .toList();
      } else if (json['ALLFile'] is Map) {
        allFile = (List.generate(1, (index) => json['ALLFile']))
            .map((v) => CameraFile().fromJson(v))
            .toList();
      }
    }

    return this;
  }
}

class CameraFile with JsonConvert<CameraFile> {
  @JSONField(name: "File")
  CameraFileInfo? file;
}

class CameraFileInfo with JsonConvert<CameraFileInfo> {
  @JSONField(name: "NAME")
  String? name;
  @JSONField(name: "FPATH")
  String? filePath;
  @JSONField(name: "SIZE")
  String? size;
  @JSONField(name: "TIMECODE")
  String? timeCode;
  @JSONField(name: "TIME")
  String? time;
  @JSONField(name: "ATTR")
  String? attr;
}
