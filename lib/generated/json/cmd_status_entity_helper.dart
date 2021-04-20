import 'package:xcam_one/models/cmd_status_entity.dart';

cmdStatusEntityFromJson(CmdStatusEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = CmdStatusFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> cmdStatusEntityToJson(CmdStatusEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

cmdStatusFunctionFromJson(CmdStatusFunction data, Map<String, dynamic> json) {
	if (json['Cmd'] != null) {
		data.cmd = json['Cmd'] is String
				? int.tryParse(json['Cmd'])
				: json['Cmd'].toInt();
	}
	if (json['Status'] != null) {
		data.status = json['Status'] is String
				? int.tryParse(json['Status'])
				: json['Status'].toInt();
	}
	return data;
}

Map<String, dynamic> cmdStatusFunctionToJson(CmdStatusFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.status;
	return data;
}