/// status : true
/// message : "Registration Successfully"
/// data : {"id":16,"email":"testdev@yopmail.com","username":"Praveenkumawat5633","first_name":"Praveen","last_name":"kumawat","phone":8386084252,"dob":"1998-09-20","gender":"Male","city":"Jaipur","is_verified":false,"waiting_list":false,"like_count":0,"rating":0,"status":"Active","token_detail":"b7ed90a8e0c87b4c07cfb4fafa90779856d1eb1d","image_detail":null,"user_profile":null,"is_agree":true,"uuid":"92cd6264-08af-4098-b2c9-3729f8f137f9"}

class UserModel {
  String? detail;
  UserModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  UserModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
UserModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => UserModel(  status: status ?? _status,
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

/// id : 16
/// email : "testdev@yopmail.com"
/// username : "Praveenkumawat5633"
/// first_name : "Praveen"
/// last_name : "kumawat"
/// phone : 8386084252
/// dob : "1998-09-20"
/// gender : "Male"
/// city : "Jaipur"
/// is_verified : false
/// waiting_list : false
/// like_count : 0
/// rating : 0
/// status : "Active"
/// token_detail : "b7ed90a8e0c87b4c07cfb4fafa90779856d1eb1d"
/// image_detail : null
/// user_profile : null
/// is_agree : true
/// uuid : "92cd6264-08af-4098-b2c9-3729f8f137f9"

class Data {
  Data({
      num? id, 
      String? email, 
      String? username, 
      String? firstName, 
      String? lastName, 
      num? phone, 
      String? dob, 
      String? gender, 
      String? city, 
      bool? isVerified, 
      bool? waitingList, 
      num? likeCount, 
      num? rating, 
      String? status, 
      String? tokenDetail, 
      dynamic imageDetail, 
      dynamic userProfile, 
      bool? isAgree, 
      String? uuid,}){
    _id = id;
    _email = email;
    _username = username;
    _firstName = firstName;
    _lastName = lastName;
    _phone = phone;
    _dob = dob;
    _gender = gender;
    _city = city;
    _isVerified = isVerified;
    _waitingList = waitingList;
    _likeCount = likeCount;
    _rating = rating;
    _status = status;
    _tokenDetail = tokenDetail;
    _imageDetail = imageDetail;
    _userProfile = userProfile;
    _isAgree = isAgree;
    _uuid = uuid;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _email = json['email'];
    _username = json['username'];
    _firstName = json['first_name'];
    _lastName = json['last_name'];
    _phone = json['phone'];
    _dob = json['dob'];
    _gender = json['gender'];
    _city = json['city'];
    _isVerified = json['is_verified'];
    _waitingList = json['waiting_list'];
    _likeCount = json['like_count'];
    _rating = json['rating'];
    _status = json['status'];
    _tokenDetail = json['token_detail'];
    _imageDetail = json['image_detail'];
    _userProfile = json['user_profile'];
    _isAgree = json['is_agree'];
    _uuid = json['uuid'];
  }
  num? _id;
  String? _email;
  String? _username;
  String? _firstName;
  String? _lastName;
  num? _phone;
  String? _dob;
  String? _gender;
  String? _city;
  bool? _isVerified;
  bool? _waitingList;
  num? _likeCount;
  num? _rating;
  String? _status;
  String? _tokenDetail;
  dynamic _imageDetail;
  dynamic _userProfile;
  bool? _isAgree;
  String? _uuid;
Data copyWith({  num? id,
  String? email,
  String? username,
  String? firstName,
  String? lastName,
  num? phone,
  String? dob,
  String? gender,
  String? city,
  bool? isVerified,
  bool? waitingList,
  num? likeCount,
  num? rating,
  String? status,
  String? tokenDetail,
  dynamic imageDetail,
  dynamic userProfile,
  bool? isAgree,
  String? uuid,
}) => Data(  id: id ?? _id,
  email: email ?? _email,
  username: username ?? _username,
  firstName: firstName ?? _firstName,
  lastName: lastName ?? _lastName,
  phone: phone ?? _phone,
  dob: dob ?? _dob,
  gender: gender ?? _gender,
  city: city ?? _city,
  isVerified: isVerified ?? _isVerified,
  waitingList: waitingList ?? _waitingList,
  likeCount: likeCount ?? _likeCount,
  rating: rating ?? _rating,
  status: status ?? _status,
  tokenDetail: tokenDetail ?? _tokenDetail,
  imageDetail: imageDetail ?? _imageDetail,
  userProfile: userProfile ?? _userProfile,
  isAgree: isAgree ?? _isAgree,
  uuid: uuid ?? _uuid,
);
  num? get id => _id;
  String? get email => _email;
  String? get username => _username;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  num? get phone => _phone;
  String? get dob => _dob;
  String? get gender => _gender;
  String? get city => _city;
  bool? get isVerified => _isVerified;
  bool? get waitingList => _waitingList;
  num? get likeCount => _likeCount;
  num? get rating => _rating;
  String? get status => _status;
  String? get tokenDetail => _tokenDetail;
  dynamic get imageDetail => _imageDetail;
  dynamic get userProfile => _userProfile;
  bool? get isAgree => _isAgree;
  String? get uuid => _uuid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['email'] = _email;
    map['username'] = _username;
    map['first_name'] = _firstName;
    map['last_name'] = _lastName;
    map['phone'] = _phone;
    map['dob'] = _dob;
    map['gender'] = _gender;
    map['city'] = _city;
    map['is_verified'] = _isVerified;
    map['waiting_list'] = _waitingList;
    map['like_count'] = _likeCount;
    map['rating'] = _rating;
    map['status'] = _status;
    map['token_detail'] = _tokenDetail;
    map['image_detail'] = _imageDetail;
    map['user_profile'] = _userProfile;
    map['is_agree'] = _isAgree;
    map['uuid'] = _uuid;
    return map;
  }

}