/// status : true
/// message : "Membership count fetched successfully."
/// data : {"membership_count":98}

class MembershipCountModel {
  String? detail;
  MembershipCountModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  MembershipCountModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
MembershipCountModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => MembershipCountModel(  status: status ?? _status,
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

/// membership_count : 98

class Data {
  Data({
      num? membershipCount,}){
    _membershipCount = membershipCount;
}

  Data.fromJson(dynamic json) {
    _membershipCount = json['membership_count'];
  }
  num? _membershipCount;
Data copyWith({  num? membershipCount,
}) => Data(  membershipCount: membershipCount ?? _membershipCount,
);
  num? get membershipCount => _membershipCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['membership_count'] = _membershipCount;
    return map;
  }

}