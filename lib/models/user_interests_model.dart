/// status : true
/// message : "interests List fetched successfully."
/// data : [{"id":1,"name":"Dining Out","description":"Exploring new restaurants, cafes, and food spots."},{"id":2,"name":"Cocktail Tasting","description":"Trying out signature cocktails and mixology."},{"id":3,"name":"Wine Tasting","description":"Visiting vineyards and wine bars."},{"id":4,"name":"Clubbing & Nightlife","description":"Enjoying music, dancing, and nightlife."},{"id":5,"name":"Coffee Shop Visits","description":"Relaxing in cozy coffee shops."},{"id":6,"name":"Bar Hopping","description":"Exploring different bars in a city."},{"id":7,"name":"Food Festivals","description":"Attending food trucks and culinary events."},{"id":8,"name":"Cooking Classes","description":"Learning new recipes together."},{"id":9,"name":"Escape Rooms","description":"Solving puzzles as a team."},{"id":10,"name":"Picnics","description":"Enjoying outdoor meals in parks."},{"id":11,"name":"Hiking","description":"Exploring trails and nature walks."},{"id":12,"name":"Camping","description":"Spending nights under the stars."},{"id":13,"name":"Beach Days","description":"Relaxing by the sea."},{"id":14,"name":"Kayaking & Canoeing","description":"Water adventures in rivers or lakes."},{"id":15,"name":"Tennis","description":"Playing a casual game or match."},{"id":16,"name":"Golfing","description":"Spending a day on the green."},{"id":17,"name":"Bowling","description":"Enjoying a friendly competition."},{"id":18,"name":"Yoga Classes","description":"Trying out yoga sessions together."},{"id":19,"name":"Gym Workouts","description":"Motivating each other to stay fit."},{"id":20,"name":"Swimming","description":"Spending time in the pool."},{"id":21,"name":"Art Galleries","description":"Visiting contemporary or classic art exhibitions."},{"id":22,"name":"Museum Hopping","description":"Exploring history, science, or themed museums."},{"id":23,"name":"Concerts & Live Music","description":"Enjoying different genres of music."},{"id":24,"name":"Theater & Drama","description":"Watching plays and musicals."},{"id":25,"name":"Film Festivals","description":"Attending indie or international film screenings."},{"id":26,"name":"Board Games & Card Games","description":"Friendly competition at game nights."},{"id":27,"name":"Video Gaming","description":"Playing console or PC games together."},{"id":28,"name":"Karaoke Nights","description":"Singing favorite songs out loud."},{"id":29,"name":"Trivia Nights","description":"Testing knowledge in pubs or online."},{"id":30,"name":"Mini Golf","description":"Enjoying casual golf courses."}]

class UserInterestsModel {
  String? detail;
  UserInterestsModel({
    bool? status,
    String? message,
    List<UserInterestsData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  UserInterestsModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(UserInterestsData.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<UserInterestsData>? _data;

  UserInterestsModel copyWith({
    bool? status,
    String? message,
    List<UserInterestsData>? data,
  }) =>
      UserInterestsModel(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  List<UserInterestsData>? get data => _data;

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

/// id : 1
/// name : "Dining Out"
/// description : "Exploring new restaurants, cafes, and food spots."

class UserInterestsData {
  UserInterestsData({
    num? id,
    String? name,
    String? description,
  }) {
    _id = id;
    _name = name;
    _description = description;
  }

  UserInterestsData.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _description = json['description'];
  }

  num? _id;
  String? _name;
  String? _description;

  UserInterestsData copyWith({
    num? id,
    String? name,
    String? description,
  }) =>
      UserInterestsData(
        id: id ?? _id,
        name: name ?? _name,
        description: description ?? _description,
      );

  num? get id => _id;

  String? get name => _name;

  String? get description => _description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['description'] = _description;
    return map;
  }
}
