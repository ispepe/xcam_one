/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import "package:collection/collection.dart";
import 'package:intl/intl.dart';

import 'package:xcam_one/models/camera_file_entity.dart';

class PhotoState extends ChangeNotifier {
  List<AssetEntity> _photos = [];

  List<AssetEntity> get photos => _photos;

  Map<String, List<AssetEntity>> _photoGroup = {};

  Map<String, List<AssetEntity>> get photoGroup => _photoGroup;

  Future<void> refreshPhonePhoto() async {
    final option = FilterOption(
      sizeConstraint: SizeConstraint(
        minWidth: 0,
        maxWidth: 100000,
        minHeight: 0,
        maxHeight: 100000,
        ignoreSize: true,
      ),
    );

    final galleryList = await PhotoManager.getAssetPathList(
      type: RequestType.image, // 只需要查看图片
      hasAll: true,
      onlyAll: true,
      filterOption: FilterOptionGroup()
        ..setOption(AssetType.image, option)
        ..addOrderOption(
          OrderOption(
            type: OrderOptionType.updateDate,
            asc: false,
          ),
        ),
    );

    /// TODO: 4/11/21 待处理 默认显示50张，通过下来刷新显示剩余图片
    /// FIXME: 4/11/21 待增加容错处理
    _photos = await galleryList[0]
        .getAssetListRange(start: 0, end: galleryList[0].assetCount);

    final DateTime now = DateTime.now();
    _photoGroup = groupBy(_photos, (photo) {
      if (now.year != photo.modifiedDateTime.year) {
        // ignore: lines_longer_than_80_chars
        return '${photo.modifiedDateTime.year}年${photo.modifiedDateTime.month}月${photo.modifiedDateTime.day}日';
      } else if (photo.modifiedDateTime.month == now.month) {
        if (now.day == photo.modifiedDateTime.day) {
          return '今天';
        } else if (now.day - 1 == photo.modifiedDateTime.day) {
          return '昨天';
        } else {
          // ignore: lines_longer_than_80_chars
          return '${photo.modifiedDateTime.month}月${photo.modifiedDateTime.day}日';
        }
      } else {
        return '${photo.modifiedDateTime.month}月${photo.modifiedDateTime.day}日';
      }
    });

    notifyListeners();
  }

  List<CameraFile>? _allFile;

  List<CameraFile>? get allFile => _allFile;

  void cameraFileRemoveAt(index) {
    if (_allFile != null && allFile!.length > index) {
      _allFile!.removeAt(index);
    }
    _groupByCameraFile();
    notifyListeners();
  }

  /// 新增
  void addCameraFiles(List<CameraFile> listFile) {
    _allFile?.addAll(listFile);
    notifyListeners();
  }

  void setAllFile(List<CameraFile>? value) {
    _allFile = value;
    _groupByCameraFile();
    notifyListeners();
  }

  void _groupByCameraFile() {
    /// 此处控制数量 count = 20;
    if (_allFile != null) {
      final now = DateTime.now();
      _groupFileList = groupBy(_allFile!, (CameraFile photo) {
        final format = DateFormat('yyyy/MM/dd hh:mm:ss');
        final createTime = format.parse(photo.file!.time!);
        if (now.year != createTime.year) {
          // ignore: lines_longer_than_80_chars
          return '${createTime.year}年${createTime.month}月${createTime.day}日';
        } else if (createTime.month == now.month) {
          if (now.day == createTime.day) {
            return '今天';
          } else if (now.day - 1 == createTime.day) {
            return '昨天';
          } else {
            // ignore: lines_longer_than_80_chars
            return '${createTime.month}月${createTime.day}日';
          }
        } else {
          return '${createTime.month}月${createTime.day}日';
        }
      });
    }
  }

  Map<String, List<CameraFile>>? _groupFileList;

  Map<String, List<CameraFile>>? get groupFileList => _groupFileList;
}
