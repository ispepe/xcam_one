import 'package:xcam_one/models/wifi_app_mode_entity.dart';

wifiAppModeEntityFromJson(WifiAppModeEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = WifiAppModeFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> wifiAppModeEntityToJson(WifiAppModeEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

wifiAppModeFunctionFromJson(WifiAppModeFunction data, Map<String, dynamic> json) {
	if (json['Cmd'] != null) {
		data.cmd = json['Cmd'] is String
				? int.tryParse(json['Cmd'])
				: json['Cmd'].toInt();
	}
	if (json['Status'] != null) {
		data.wifiAppMode = json['Status'] is String
				? int.tryParse(json['Status'])
				: json['Status'].toInt();
	}
	return data;
}

Map<String, dynamic> wifiAppModeFunctionToJson(WifiAppModeFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.wifiAppMode;
	return data;
}