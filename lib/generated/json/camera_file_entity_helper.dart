import 'package:xcam_one/models/camera_file_entity.dart';

cameraFileListEntityFromJson(CameraFileListEntity data, Map<String, dynamic> json) {
	if (json['LIST'] != null) {
		data.list = CameraFileList().fromJson(json['LIST']);
	}
	return data;
}

Map<String, dynamic> cameraFileListEntityToJson(CameraFileListEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['LIST'] = entity.list?.toJson();
	return data;
}

cameraFileListFromJson(CameraFileList data, Map<String, dynamic> json) {
	if (json['ALLFile'] != null) {
		data.allFile = (json['ALLFile'] as List).map((v) => CameraFile().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> cameraFileListToJson(CameraFileList entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['ALLFile'] =  entity.allFile?.map((v) => v.toJson())?.toList();
	return data;
}

cameraFileFromJson(CameraFile data, Map<String, dynamic> json) {
	if (json['File'] != null) {
		data.file = CameraFileInfo().fromJson(json['File']);
	}
	return data;
}

Map<String, dynamic> cameraFileToJson(CameraFile entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['File'] = entity.file?.toJson();
	return data;
}

cameraFileInfoFromJson(CameraFileInfo data, Map<String, dynamic> json) {
	if (json['NAME'] != null) {
		data.name = json['NAME'].toString();
	}
	if (json['FPATH'] != null) {
		data.filePath = json['FPATH'].toString();
	}
	if (json['SIZE'] != null) {
		data.size = json['SIZE'].toString();
	}
	if (json['TIMECODE'] != null) {
		data.timeCode = json['TIMECODE'].toString();
	}
	if (json['TIME'] != null) {
		data.time = json['TIME'].toString();
	}
	if (json['ATTR'] != null) {
		data.attr = json['ATTR'].toString();
	}
	return data;
}

Map<String, dynamic> cameraFileInfoToJson(CameraFileInfo entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['NAME'] = entity.name;
	data['FPATH'] = entity.filePath;
	data['SIZE'] = entity.size;
	data['TIMECODE'] = entity.timeCode;
	data['TIME'] = entity.time;
	data['ATTR'] = entity.attr;
	return data;
}