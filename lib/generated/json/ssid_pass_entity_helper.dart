/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:xcam_one/models/ssid_pass_entity.dart';

ssidPassEntityFromJson(SsidPassEntity data, Map<String, dynamic> json) {
	if (json['LIST'] != null) {
		data.xLIST = SsidPassLIST().fromJson(json['LIST']);
	}
	return data;
}

Map<String, dynamic> ssidPassEntityToJson(SsidPassEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['LIST'] = entity.xLIST?.toJson();
	return data;
}

ssidPassLISTFromJson(SsidPassLIST data, Map<String, dynamic> json) {
	if (json['SSID'] != null) {
		data.sSID = json['SSID'].toString();
	}
	if (json['PASSPHRASE'] != null) {
		data.pASSPHRASE = json['PASSPHRASE'].toString();
	}
	return data;
}

Map<String, dynamic> ssidPassLISTToJson(SsidPassLIST entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['SSID'] = entity.sSID;
	data['PASSPHRASE'] = entity.pASSPHRASE;
	return data;
}