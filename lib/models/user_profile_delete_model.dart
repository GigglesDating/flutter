/// status : true
/// message : "User profile deleted successfully."
/// data : []

class UserProfileDeleteModel {
  String? detail;
  UserProfileDeleteModel({
      bool? status, 
      String? message, 
      List<dynamic>? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  UserProfileDeleteModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(v);
      });
    }
  }
  bool? _status;
  String? _message;
  List<dynamic>? _data;
UserProfileDeleteModel copyWith({  bool? status,
  String? message,
  List<dynamic>? data,
}) => UserProfileDeleteModel(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get status => _status;
  String? get message => _message;
  List<dynamic>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}