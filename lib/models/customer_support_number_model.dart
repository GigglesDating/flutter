/// status : true
/// message : "support number found successfully"
/// data : {"id":1,"phone_number":8121841657}

class CustomerSupportNumberModel {
  String? detail;
  CustomerSupportNumberModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  CustomerSupportNumberModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
CustomerSupportNumberModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => CustomerSupportNumberModel(  status: status ?? _status,
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

/// id : 1
/// phone_number : 8121841657

class Data {
  Data({
      num? id, 
      num? phoneNumber,}){
    _id = id;
    _phoneNumber = phoneNumber;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _phoneNumber = json['phone_number'];
  }
  num? _id;
  num? _phoneNumber;
Data copyWith({  num? id,
  num? phoneNumber,
}) => Data(  id: id ?? _id,
  phoneNumber: phoneNumber ?? _phoneNumber,
);
  num? get id => _id;
  num? get phoneNumber => _phoneNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['phone_number'] = _phoneNumber;
    return map;
  }

}