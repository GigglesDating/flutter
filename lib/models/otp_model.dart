/// status : true
/// message : "OTP validated successfully"
/// data : {"id":30,"is_agree":false,"is_first_time":false,"aadhaar_verified":false,"is_video_watched":true}

class OtpModel {
  String? detail;
  OtpModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  OtpModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
OtpModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => OtpModel(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get status => _status;
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// id : 30
/// is_agree : false
/// is_first_time : false
/// aadhaar_verified : false
/// is_video_watched : true

class Data {
  Data({
      num? id, 
      bool? isAgree, 
      bool? isFirstTime, 
      bool? aadhaarVerified, 
      bool? isVideoWatched,}){
    _id = id;
    _isAgree = isAgree;
    _isFirstTime = isFirstTime;
    _aadhaarVerified = aadhaarVerified;
    _isVideoWatched = isVideoWatched;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _isAgree = json['is_agree'];
    _isFirstTime = json['is_first_time'];
    _aadhaarVerified = json['aadhaar_verified'];
    _isVideoWatched = json['is_video_watched'];
  }
  num? _id;
  bool? _isAgree;
  bool? _isFirstTime;
  bool? _aadhaarVerified;
  bool? _isVideoWatched;
Data copyWith({  num? id,
  bool? isAgree,
  bool? isFirstTime,
  bool? aadhaarVerified,
  bool? isVideoWatched,
}) => Data(  id: id ?? _id,
  isAgree: isAgree ?? _isAgree,
  isFirstTime: isFirstTime ?? _isFirstTime,
  aadhaarVerified: aadhaarVerified ?? _aadhaarVerified,
  isVideoWatched: isVideoWatched ?? _isVideoWatched,
);
  num? get id => _id;
  bool? get isAgree => _isAgree;
  bool? get isFirstTime => _isFirstTime;
  bool? get aadhaarVerified => _aadhaarVerified;
  bool? get isVideoWatched => _isVideoWatched;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['is_agree'] = _isAgree;
    map['is_first_time'] = _isFirstTime;
    map['aadhaar_verified'] = _aadhaarVerified;
    map['is_video_watched'] = _isVideoWatched;
    return map;
  }

}