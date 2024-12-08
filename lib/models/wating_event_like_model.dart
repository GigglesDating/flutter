/// status : true
/// message : "Event liked successfully."
/// data : {"id":3,"user":19,"event":6}

class WatingEventLikeModel {
  String? detail;
  WatingEventLikeModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  WatingEventLikeModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
WatingEventLikeModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => WatingEventLikeModel(  status: status ?? _status,
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

/// id : 3
/// user : 19
/// event : 6

class Data {
  Data({
      num? id, 
      num? user, 
      num? event,}){
    _id = id;
    _user = user;
    _event = event;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _user = json['user'];
    _event = json['event'];
  }
  num? _id;
  num? _user;
  num? _event;
Data copyWith({  num? id,
  num? user,
  num? event,
}) => Data(  id: id ?? _id,
  user: user ?? _user,
  event: event ?? _event,
);
  num? get id => _id;
  num? get user => _user;
  num? get event => _event;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user'] = _user;
    map['event'] = _event;
    return map;
  }

}