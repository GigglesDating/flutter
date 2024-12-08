/// status : true
/// message : "Intro video fetched successfully."
/// data : {"intro_video":"http://192.168.29.109:8000/media/intro_video/WhatsApp_Video_2024-11-22_at_11_drtWVKw.49.29.mp4"}

class IntroVideoModel {
  IntroVideoModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  IntroVideoModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
IntroVideoModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => IntroVideoModel(  status: status ?? _status,
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

/// intro_video : "http://192.168.29.109:8000/media/intro_video/WhatsApp_Video_2024-11-22_at_11_drtWVKw.49.29.mp4"

class Data {
  Data({
      String? introVideo,}){
    _introVideo = introVideo;
}

  Data.fromJson(dynamic json) {
    _introVideo = json['intro_video'];
  }
  String? _introVideo;
Data copyWith({  String? introVideo,
}) => Data(  introVideo: introVideo ?? _introVideo,
);
  String? get introVideo => _introVideo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['intro_video'] = _introVideo;
    return map;
  }

}