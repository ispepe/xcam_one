import 'package:xcam_one/models/hearbeat_entity.dart';

hearbeatEntityFromJson(HearbeatEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = HearbeatFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> hearbeatEntityToJson(HearbeatEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

hearbeatFunctionFromJson(HearbeatFunction data, Map<String, dynamic> json) {
	if (json['Cmd'] != null) {
		data.cmd = json['Cmd'].toString();
	}
	if (json['Status'] != null) {
		data.status = json['Status'].toString();
	}
	return data;
}

Map<String, dynamic> hearbeatFunctionToJson(HearbeatFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.status;
	return data;
}