import 'package:xcam_one/models/capture_entity.dart';

captureEntityFromJson(CaptureEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = CaptureFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> captureEntityToJson(CaptureEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

captureFunctionFromJson(CaptureFunction data, Map<String, dynamic> json) {
	if (json['Cmd'] != null) {
		data.cmd = json['Cmd'].toString();
	}
	if (json['Status'] != null) {
		data.status = json['Status'].toString();
	}
	if (json['File'] != null) {
		data.file = CaptureFunctionFile().fromJson(json['File']);
	}
	if (json['FREEPICNUM'] != null) {
		data.freePicNum = json['FREEPICNUM'].toString();
	}
	return data;
}

Map<String, dynamic> captureFunctionToJson(CaptureFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Cmd'] = entity.cmd;
	data['Status'] = entity.status;
	data['File'] = entity.file?.toJson();
	data['FREEPICNUM'] = entity.freePicNum;
	return data;
}

captureFunctionFileFromJson(CaptureFunctionFile data, Map<String, dynamic> json) {
	if (json['NAME'] != null) {
		data.name = json['NAME'].toString();
	}
	if (json['FPATH'] != null) {
		data.fPath = json['FPATH'].toString();
	}
	return data;
}

Map<String, dynamic> captureFunctionFileToJson(CaptureFunctionFile entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['NAME'] = entity.name;
	data['FPATH'] = entity.fPath;
	return data;
}