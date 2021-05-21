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
  /// 显示单元固定为20个
  final int showUnit = 20;

  List<AssetEntity> _photos = [];

  List<AssetEntity> get photos => _photos;

  Map<String, List<AssetEntity>> _photoGroup = {};

  Map<String, List<AssetEntity>> get photoGroup => _photoGroup;

  /// 当前已显示的手机相册照片数量
  int _phonePhotoCount = 0;
  List<AssetPathEntity>? _galleryList;

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

    _galleryList = await PhotoManager.getAssetPathList(
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

    _phonePhotoCount = 0;
    _photos.clear();
    await loadPhonePhoto();
  }

  Future<bool> loadPhonePhoto() async {
    int count = showUnit;

    if (_galleryList != null) {
      if (_galleryList![0].assetCount - _phonePhotoCount < count) {
        count = _galleryList![0].assetCount - _phonePhotoCount;
      }

      if (_galleryList![0].assetCount != 0) {
        _photos.addAll(await _galleryList![0].getAssetListRange(
            start: _phonePhotoCount, end: _phonePhotoCount + count));

        /// 更新当前数量
        _phonePhotoCount += count;

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
      }
      notifyListeners();
      return _phonePhotoCount == _galleryList![0].assetCount;
    } else {
      notifyListeners();
      return true;
    }
  }

  /// 当前要显示的相机照片总数
  int _cameraPhotoCount = 0;

  /// 所有文件
  List<CameraFile>? _allFile;

  List<CameraFile>? get allFile => _allFile;

  void cameraFileRemoveAt(index) {
    if (_allFile != null && allFile!.length > index) {
      _allFile!.removeAt(index);
    }

    _cameraPhotoCount--;
    loadCameraFile();
  }

  set allFile(List<CameraFile>? value) {
    _allFile = value;

    /// 当数据重新被设置后应该初始化
    _cameraPhotoCount = 0;
    loadCameraFile();
  }

  /// 返回是否还有更多
  bool loadCameraFile() {
    _cameraPhotoCount += 20;

    if (_allFile != null) {
      if (_cameraPhotoCount > _allFile!.length) {
        _cameraPhotoCount = _allFile!.length;
      }

      /// FIXME 4/21/21 待修复 每次都从0开始获取，当数据非常大的时候会导致一次获取失败
      final List<CameraFile> currentCameraFile =
          _allFile!.slice(0, _cameraPhotoCount);

      final now = DateTime.now();
      _groupFileList = groupBy(currentCameraFile, (CameraFile photo) {
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

    notifyListeners();

    return _cameraPhotoCount == (allFile?.length ?? 0);
  }

  /// 当前分组
  Map<String, List<CameraFile>>? _groupFileList;

  Map<String, List<CameraFile>>? get groupFileList => _groupFileList;

  /// 是否进入多选状态
  bool _isMultipleSelect = false;

  bool get isMultipleSelect => _isMultipleSelect;

  set isMultipleSelect(bool value) {
    _isMultipleSelect = value;
    notifyListeners();
  }

  /// 当前已选择列表
  List<int> _listSelect = [];

  List<int> get listSelect => _listSelect;

  set listSelect(List<int> value) {
    _listSelect = value;
    notifyListeners();
  }

  /// 是否全选
  bool _isAllSelect = false;

  bool get isAllSelect => _isAllSelect;

  set isAllSelect(bool value) {
    _isAllSelect = value;
    notifyListeners();
  }
}
