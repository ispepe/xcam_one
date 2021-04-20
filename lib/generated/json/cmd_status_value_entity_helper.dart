import 'package:xcam_one/models/cmd_status_value_entity.dart';

cmdStatusValueEntityFromJson(CmdStatusValueEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = CmdStatusValueFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> cmdStatusValueEntityToJson(CmdStatusValueEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

cmdStatusValueFunctionFromJson(CmdStatusValueFunction data, Map<String, dynamic> json) {
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
	if (json['Value'] != null) {
		data.value = json['Value'] is String
				? int.tryParse(json['Value'])
				: json['Value'].toInt();
	}
	return data;
}

Map<String, dynamic> cmdStatusValueFunctionToJson(CmdStatusValueFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.status;
	data['Value'] = entity.value;
	return data;
}