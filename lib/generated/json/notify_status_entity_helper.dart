import 'package:xcam_one/models/notify_status_entity.dart';

notifyStatusEntityFromJson(NotifyStatusEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = NotifyStatusFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> notifyStatusEntityToJson(NotifyStatusEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

notifyStatusFunctionFromJson(NotifyStatusFunction data, Map<String, dynamic> json) {
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

Map<String, dynamic> notifyStatusFunctionToJson(NotifyStatusFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.status;
	return data;
}