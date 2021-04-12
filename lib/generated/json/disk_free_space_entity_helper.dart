import 'package:xcam_one/models/disk_free_space_entity.dart';

diskFreeSpaceEntityFromJson(DiskFreeSpaceEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = DiskFreeSpaceFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> diskFreeSpaceEntityToJson(DiskFreeSpaceEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

diskFreeSpaceFunctionFromJson(DiskFreeSpaceFunction data, Map<String, dynamic> json) {
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
		data.space = json['Value'] is String
				? int.tryParse(json['Value'])
				: json['Value'].toInt();
	}
	return data;
}

Map<String, dynamic> diskFreeSpaceFunctionToJson(DiskFreeSpaceFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.status;
	data['Value'] = entity.space;
	return data;
}