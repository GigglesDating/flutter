class Otpverify {
  bool? status;
  String? message;
  Data? data;

  Otpverify({this.status, this.message, this.data});

  Otpverify.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class Data {
  int? id;
  bool? isAgree;
  bool? isFirstTime;
  bool? aadhaarVerified;

  Data({this.id, this.isAgree, this.isFirstTime, this.aadhaarVerified});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    isAgree = json['is_agree'] as bool?;
    isFirstTime = json['is_first_time'] as bool?;
    aadhaarVerified = json['aadhaar_verified'] as bool?;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_agree': isAgree,
      'is_first_time': isFirstTime,
      'aadhaar_verified': aadhaarVerified,
    };
  }
}
