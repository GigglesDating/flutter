class MembershipCountModel {
  bool? status;
  String? message;
  Data? data;

  MembershipCountModel({this.status, this.message, this.data});

  MembershipCountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  int? totalUsers;

  Data({this.totalUsers});

  Data.fromJson(Map<String, dynamic> json) {
    totalUsers = json['total_users'];
  }

  Map<String, dynamic> toJson() => {
        'total_users': totalUsers,
      };
}
