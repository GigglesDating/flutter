/// status : true
/// message : "Event video fetched successfully."
/// data : {"waiting_list_video": "video_url"}

class EventVideoModel {
  EventVideoModel({
    bool? status,
    String? message,
    Data? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  EventVideoModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  bool? _status;
  String? _message;
  Data? _data;

  EventVideoModel copyWith({
    bool? status,
    String? message,
    Data? data,
  }) =>
      EventVideoModel(
        status: status ?? _status,
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

/// waiting_list_video : "video_url"

class Data {
  Data({
    String? waitingListVideo,
  }) {
    _waitingListVideo = waitingListVideo;
  }

  Data.fromJson(dynamic json) {
    _waitingListVideo = json['waiting_list_video'];
  }

  String? _waitingListVideo;

  Data copyWith({
    String? waitingListVideo,
  }) =>
      Data(
        waitingListVideo: waitingListVideo ?? _waitingListVideo,
      );

  String? get waitingListVideo => _waitingListVideo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['waiting_list_video'] = _waitingListVideo;
    return map;
  }
}
