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

enum ErrorCode {
  WIFIAPP_RET_OK,
  WIFIAPP_RET_RECORD_STARTED,
  WIFIAPP_RET_RECORD_STOPPED,
  WIFIAPP_RET_DISCONNECT,
  WIFIAPP_RET_MIC_ON,
  WIFIAPP_RET_MIC_OFF,
  WIFIAPP_RET_POWER_OFF,
  WIFIAPP_RET_REMOVE_BY_USER,
  WIFIAPP_RET_NOFILE,
  WIFIAPP_RET_EXIF_ERR,
  WIFIAPP_RET_NOBUF,
  WIFIAPP_RET_FILE_LOCKED,
  WIFIAPP_RET_FILE_ERROR,
  WIFIAPP_RET_DELETE_FAILED,
  WIFIAPP_RET_MOVIE_FULL,
  WIFIAPP_RET_MOVIE_WR_ERROR,
  WIFIAPP_RET_MOVIE_SLOW,
  WIFIAPP_RET_BATTERY_LOW,
  WIFIAPP_RET_STORAGE_FULL,
  WIFIAPP_RET_FOLDER_FULL,
  WIFIAPP_RET_FAIL,
  WIFIAPP_RET_FW_WRITE_CHK_ERR,
  WIFIAPP_RET_FW_READ2_ERR,
  WIFIAPP_RET_FW_WRITE_ERR,
  WIFIAPP_RET_FW_READ_CHK_ERR,
  WIFIAPP_RET_FW_READ_ERR,
  WIFIAPP_RET_FW_INVALID_STG,
  WIFIAPP_RET_FW_OFFSET,
  WIFIAPP_RET_PAR_ERR,
  WIFIAPP_RET_CMD_NOTFOUND,
}

extension ErrorCodeExt on ErrorCode {
  int get value => const [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        -1,
        -2,
        -3,
        -4,
        -5,
        -6,
        -7,
        -8,
        -9,
        -10,
        -11,
        -12,
        -13,
        -14,
        -15,
        -16,
        -17,
        -18,
        -19,
        -20,
        -21,
        -256
      ][index];

  String get comments => [
        'Execute successful',
        'Record is started',
        'Record is stop',
        'Wi-Fi would be disconnect',
        'Notify app NT9666x is microphone on',
        'Notify app NT9666x is microphone off',
        'Notify app NT9666x power off',
        'Notify app is disconnected, because new user connected to NT9666x',
        'No file',
        'File EXIF error',
        'No buffer',
        'File is read only',
        'File delete error',
        'Delete fail',
        'Storage full while recording',
        'Write storage error while recording',
        'Slow card while recording',
        'Battery low',
        'Storage full',
        'Folder full',
        'Execute error',
        'Write FW checksum failed',
        'Read FW from NAND failed (for write checking)',
        'Write FW to NAND error',
        'Read FW checksum failed',
        'FW doesn\'t exist or read error',
        'Invalid source storage',
        'Firmware update error code offset',
        'Command parameter error',
        'Command not found',
      ][index];
}

class NotifyStatusEntity with JsonConvert<NotifyStatusEntity> {
  @JSONField(name: "Function")
  NotifyStatusFunction? function;
}

class NotifyStatusFunction with JsonConvert<NotifyStatusFunction> {
  @JSONField(name: "Cmd")
  int? cmd;
  @JSONField(name: "Status")
  int? status;
}
