import 'package:xcam_one/models/iq_info_entity.dart';

iQInfoEntityFromJson(IQInfoEntity data, Map<String, dynamic> json) {
	if (json['Function'] != null) {
		data.function = IQInfoFunction().fromJson(json['Function']);
	}
	return data;
}

Map<String, dynamic> iQInfoEntityToJson(IQInfoEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Function'] = entity.function?.toJson();
	return data;
}

iQInfoFunctionFromJson(IQInfoFunction data, Map<String, dynamic> json) {
	if (json['Shdr'] != null) {
		data.shdr = json['Shdr'] is String
				? int.tryParse(json['Shdr'])
				: json['Shdr'].toInt();
	}
	if (json['Wdr'] != null) {
		data.wdr = json['Wdr'] is String
				? int.tryParse(json['Wdr'])
				: json['Wdr'].toInt();
	}
	if (json['Ev'] != null) {
		data.ev = json['Ev'] is String
				? int.tryParse(json['Ev'])
				: json['Ev'].toInt();
	}
	if (json['Sharpness'] != null) {
		data.sharpness = json['Sharpness'] is String
				? int.tryParse(json['Sharpness'])
				: json['Sharpness'].toInt();
	}
	if (json['Saturation'] != null) {
		data.saturation = json['Saturation'] is String
				? int.tryParse(json['Saturation'])
				: json['Saturation'].toInt();
	}
	if (json['Iso'] != null) {
		data.iso = json['Iso'] is String
				? int.tryParse(json['Iso'])
				: json['Iso'].toInt();
	}
	if (json['Status'] != null) {
		data.status = json['Status'] is String
				? int.tryParse(json['Status'])
				: json['Status'].toInt();
	}
	return data;
}

Map<String, dynamic> iQInfoFunctionToJson(IQInfoFunction entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Shdr'] = entity.shdr;
	data['Wdr'] = entity.wdr;
	data['Ev'] = entity.ev;
	data['Sharpness'] = entity.sharpness;
	data['Saturation'] = entity.saturation;
	data['Iso'] = entity.iso;
	data['Status'] = entity.status;
	return data;
}