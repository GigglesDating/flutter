/// status : true
/// message : "User profile Created successfully."
/// data : {"id":24,"gender_orientation":"Straight","gender_preferences":"Male","dating_preferences":["Relationship"],"age_preference":"21-30","interests":["Dining Out","Clubbing & Nightlife","Bar Hopping"],"bio":"hi looking for someone","image_detail":["http://0.0.0.0:8000/media/home/user/images/Screenshot_from_2023-10-12_18-42-05_aPI5JZr.png","http://0.0.0.0:8000/media/home/user/images/Screenshot_from_2024-01-24_16-32-05_XyPFqgB.png","http://0.0.0.0:8000/media/home/user/images/Screenshot_from_2024-01-11_13-05-59_tvW7hIS.png"],"is_first_time":true}

class UserProfileCreationModel {
  String? detail;
  UserProfileCreationModel({
      bool? status, 
      String? message, 
      Data? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  UserProfileCreationModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;
UserProfileCreationModel copyWith({  bool? status,
  String? message,
  Data? data,
}) => UserProfileCreationModel(  status: status ?? _status,
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

/// id : 24
/// gender_orientation : "Straight"
/// gender_preferences : "Male"
/// dating_preferences : ["Relationship"]
/// age_preference : "21-30"
/// interests : ["Dining Out","Clubbing & Nightlife","Bar Hopping"]
/// bio : "hi looking for someone"
/// image_detail : ["http://0.0.0.0:8000/media/home/user/images/Screenshot_from_2023-10-12_18-42-05_aPI5JZr.png","http://0.0.0.0:8000/media/home/user/images/Screenshot_from_2024-01-24_16-32-05_XyPFqgB.png","http://0.0.0.0:8000/media/home/user/images/Screenshot_from_2024-01-11_13-05-59_tvW7hIS.png"]
/// is_first_time : true

class Data {
  Data({
      num? id, 
      String? genderOrientation, 
      String? genderPreferences, 
      List<String>? datingPreferences, 
      String? agePreference, 
      List<String>? interests, 
      String? bio, 
      List<String>? imageDetail, 
      bool? isFirstTime,}){
    _id = id;
    _genderOrientation = genderOrientation;
    _genderPreferences = genderPreferences;
    _datingPreferences = datingPreferences;
    _agePreference = agePreference;
    _interests = interests;
    _bio = bio;
    _imageDetail = imageDetail;
    _isFirstTime = isFirstTime;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _genderOrientation = json['gender_orientation'];
    _genderPreferences = json['gender_preferences'];
    _datingPreferences = json['dating_preferences'] != null ? json['dating_preferences'].cast<String>() : [];
    _agePreference = json['age_preference'];
    _interests = json['interests'] != null ? json['interests'].cast<String>() : [];
    _bio = json['bio'];
    _imageDetail = json['image_detail'] != null ? json['image_detail'].cast<String>() : [];
    _isFirstTime = json['is_first_time'];
  }
  num? _id;
  String? _genderOrientation;
  String? _genderPreferences;
  List<String>? _datingPreferences;
  String? _agePreference;
  List<String>? _interests;
  String? _bio;
  List<String>? _imageDetail;
  bool? _isFirstTime;
Data copyWith({  num? id,
  String? genderOrientation,
  String? genderPreferences,
  List<String>? datingPreferences,
  String? agePreference,
  List<String>? interests,
  String? bio,
  List<String>? imageDetail,
  bool? isFirstTime,
}) => Data(  id: id ?? _id,
  genderOrientation: genderOrientation ?? _genderOrientation,
  genderPreferences: genderPreferences ?? _genderPreferences,
  datingPreferences: datingPreferences ?? _datingPreferences,
  agePreference: agePreference ?? _agePreference,
  interests: interests ?? _interests,
  bio: bio ?? _bio,
  imageDetail: imageDetail ?? _imageDetail,
  isFirstTime: isFirstTime ?? _isFirstTime,
);
  num? get id => _id;
  String? get genderOrientation => _genderOrientation;
  String? get genderPreferences => _genderPreferences;
  List<String>? get datingPreferences => _datingPreferences;
  String? get agePreference => _agePreference;
  List<String>? get interests => _interests;
  String? get bio => _bio;
  List<String>? get imageDetail => _imageDetail;
  bool? get isFirstTime => _isFirstTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['gender_orientation'] = _genderOrientation;
    map['gender_preferences'] = _genderPreferences;
    map['dating_preferences'] = _datingPreferences;
    map['age_preference'] = _agePreference;
    map['interests'] = _interests;
    map['bio'] = _bio;
    map['image_detail'] = _imageDetail;
    map['is_first_time'] = _isFirstTime;
    return map;
  }

}