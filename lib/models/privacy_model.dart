/// status : true
/// message : "Privacy policy fetched successfully."
/// data : {"id":1, "privacy_policy":"This is the privacy policy."}

class PrivacyPolicyModel {
   String? detail;
  PrivacyPolicyModel({
    bool? status,
    String? message,
    Data? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  PrivacyPolicyModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;

  PrivacyPolicyModel copyWith({
    bool? status,
    String? message,
    Data? data,
  }) =>
      PrivacyPolicyModel(
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

/// id : 1
/// privacy_policy : "This is the privacy policy."

class Data {
  Data({
    int? id,
    String? privacyPolicy,
  }) {
    _id = id;
    _privacyPolicy = privacyPolicy;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _privacyPolicy = json['privacy_policy'];
  }
  int? _id;
  String? _privacyPolicy;

  Data copyWith({
    int? id,
    String? privacyPolicy,
  }) =>
      Data(
        id: id ?? _id,
        privacyPolicy: privacyPolicy ?? _privacyPolicy,
      );

  int? get id => _id;
  String? get privacyPolicy => _privacyPolicy;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['privacy_policy'] = _privacyPolicy;
    return map;
  }
}
