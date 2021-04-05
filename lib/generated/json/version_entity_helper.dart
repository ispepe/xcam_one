import 'package:xcam_one/models/version_entity.dart';

versionEntityFromJson(VersionEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = VersionFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> versionEntityToJson(VersionEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

versionFunctionFromJson(VersionFunction data, Map<String, dynamic> json) {
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
	if (json['String'] != null) {
		data.version = json['String'].toString();
	}
	return data;
}

Map<String, dynamic> versionFunctionToJson(VersionFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.status;
	data['String'] = entity.version;
	return data;
}