/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

class HttpApi {
  /// 心跳检测,返回成功即可
  static const String heartbeat = '?custom=1&cmd=3016';

  /// 检测固件版本 WIFIAPP_CMD_VERSION
  static const String queryVersion = '?custom=1&cmd=3012';

  /// 获取电量
  static const String getBatteryLevel = '?custom=1&cmd=3019';

  /// 拍照
  static const String capture = '?custom=1&cmd=1001';

  /// 可拍摄张数
  static const String freeCaptureNum = '?custom=1&cmd=1003';

  /// 查询当前状态
  static const String queryCurrentStatus = '?custom=1&cmd=3014';

  /// 更改模式 /// NOTE: 4/7/21 待注意 模式不匹配会导致拍摄异常
  static const String appModeChange = '?custom=1&cmd=3001&par=';

  /// RSTP拉流 rtsp://192.168.1.254/xxxx.mov
  static const String rtsp = 'rtsp://192.168.1.254/xxxx.mov';

  /// HTTP MJPG streaming
  static const String streamingUrl = 'http://192.168.1.254:8192';

  /// 获取硬件容量
  static const String getHardwareCapacity = '?custom=1&cmd=3022';

  /// 获取存储空间
  static const String getDiskFreeSpace = '?custom=1&cmd=3017';

  /// 获取文件列表
  static const String getFileList = '?custom=1&cmd=3015';

  /// 获取相机照片缩略图 http://192.168.1.254/NOVATEK/PHOTO/20210402_144607A.JPG?custom=1&cmd=4001
  static const String getThumbnail = '?custom=1&cmd=4001';

  /// 获取显示手机显示图片 http://192.168.1.254/NOVATEK/PHOTO/20210402_144607A.JPG?custom=1&cmd=4002
  static const String getScreennail = '?custom=1&cmd=4002';

  /// 删除照片 Http://192.168.1.254/?custom=1&cmd=4003&str=A:\CARDV\PHOTO\2014_0506_000000.0001.JPG
  static const String deleteFile = '?custom=1&cmd=4003&str=';

  /// 格式化相册

  /// 重置相机设置

  /// socket 通知客户端电池电量低、存储卡满 端口号3333

}
