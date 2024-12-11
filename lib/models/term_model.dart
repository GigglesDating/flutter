/// status : true
/// message : "Terms of Use fetched successfully."
/// data : {"id":1, "terms_and_conditions":"These are the terms and conditions."}

class TermsOfUse {
  String? detail;
  TermsOfUse({
    bool? status,
    String? message,
    Data? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  TermsOfUse.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;

  TermsOfUse copyWith({
    bool? status,
    String? message,
    Data? data,
  }) =>
      TermsOfUse(
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
/// terms_and_conditions : "These are the terms and conditions."

class Data {
  Data({
    int? id,
    String? termsAndConditions,
  }) {
    _id = id;
    _termsAndConditions = termsAndConditions;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _termsAndConditions = json['terms_and_conditions'];
  }
  int? _id;
  String? _termsAndConditions;

  Data copyWith({
    int? id,
    String? termsAndConditions,
  }) =>
      Data(
        id: id ?? _id,
        termsAndConditions: termsAndConditions ?? _termsAndConditions,
      );

  int? get id => _id;
  String? get termsAndConditions => _termsAndConditions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['terms_and_conditions'] = _termsAndConditions;
    return map;
  }
}
