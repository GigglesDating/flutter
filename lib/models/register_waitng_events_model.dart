/// status : true
/// message : "Event registered successfully."
/// data : {"id":17,"user":19,"event":6,"is_register":true}

class RegisterWaitngEventsModel {
  String? detail;
  RegisterWaitngEventsModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  RegisterWaitngEventsModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
RegisterWaitngEventsModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => RegisterWaitngEventsModel(  status: status ?? _status,
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

/// id : 17
/// user : 19
/// event : 6
/// is_register : true

class Data {
  Data({
      num? id, 
      num? user, 
      num? event, 
      bool? isRegister,}){
    _id = id;
    _user = user;
    _event = event;
    _isRegister = isRegister;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _user = json['user'];
    _event = json['event'];
    _isRegister = json['is_register'];
  }
  num? _id;
  num? _user;
  num? _event;
  bool? _isRegister;
Data copyWith({  num? id,
  num? user,
  num? event,
  bool? isRegister,
}) => Data(  id: id ?? _id,
  user: user ?? _user,
  event: event ?? _event,
  isRegister: isRegister ?? _isRegister,
);
  num? get id => _id;
  num? get user => _user;
  num? get event => _event;
  bool? get isRegister => _isRegister;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user'] = _user;
    map['event'] = _event;
    map['is_register'] = _isRegister;
    return map;
  }

}