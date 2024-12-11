/// status : true
/// message : "Event List fetched successfully"
/// data : [{"id":6,"event_name":"Badminton","total_seat":2,"current_seat":1,"event_type":"Sport","event_date_and_time":"2024-11-30T08:17:35Z","price":300,"discount_price":0,"event_image":"http://192.168.29.109:8000/media/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/stock-03_xlxnBfT.jpg","event_location":"https://maps.app.goo.gl/NEfWWimqzDUsRWXq6","is_like":false},{"id":5,"event_name":"Quiz","total_seat":2,"current_seat":0,"event_type":"Quiz","event_date_and_time":"2024-12-02T18:00:00Z","price":3000,"discount_price":0,"event_image":"http://192.168.29.109:8000/media/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/stock-13_cy2hviX.jpg","event_location":"https://maps.app.goo.gl/hv6oc5nDSVXGJLMc6","is_like":false},{"id":4,"event_name":"Pubg","total_seat":10,"current_seat":0,"event_type":"Game","event_date_and_time":"2024-12-02T06:00:00Z","price":100,"discount_price":0,"event_image":"http://192.168.29.109:8000/media/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/stock-11_Cc4Yqx2.jpg","event_location":"https://maps.app.goo.gl/UEbAQqDqMcHgUHgM6","is_like":false},{"id":3,"event_name":"Cricket","total_seat":22,"current_seat":1,"event_type":"Sport","event_date_and_time":"2024-12-02T06:06:14Z","price":500,"discount_price":0,"event_image":"http://192.168.29.109:8000/media/home/event/event_image/home/event/event_image/home/event/event_image/stock-06_sDBws9f.jpg","event_location":"https://maps.app.goo.gl/U75YXRaBdZjSo3JS6","is_like":true},{"id":1,"event_name":"Football","total_seat":30,"current_seat":1,"event_type":"Team","event_date_and_time":"2024-11-29T12:00:00Z","price":110,"discount_price":0,"event_image":"http://192.168.29.109:8000/media/home/event/event_image/home/event/event_image/stock-01_UcC2ZkF.jpg","event_location":"https://maps.app.goo.gl/FqJRBRa6PxcJz3T98","is_like":false}]

class WaitingEventModel {
  String? detail;
  WaitingEventModel({
      bool? status, 
      String? message, 
      List<WaitingEventData>? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  WaitingEventModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(WaitingEventData.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<WaitingEventData>? _data;
WaitingEventModel copyWith({  bool? status,
  String? message,
  List<WaitingEventData>? data,
}) => WaitingEventModel(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get status => _status;
  String? get message => _message;
  List<WaitingEventData>? get data => _data;

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

/// id : 6
/// event_name : "Badminton"
/// total_seat : 2
/// current_seat : 1
/// event_type : "Sport"
/// event_date_and_time : "2024-11-30T08:17:35Z"
/// price : 300
/// discount_price : 0
/// event_image : "http://192.168.29.109:8000/media/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/home/event/event_image/stock-03_xlxnBfT.jpg"
/// event_location : "https://maps.app.goo.gl/NEfWWimqzDUsRWXq6"
/// is_like : false
class WaitingEventData {
  WaitingEventData(
      {
      num? id, 
      String? eventName, 
      num? totalSeat, 
      num? currentSeat, 
      String? eventType, 
      String? eventDateAndTime, 
      num? price, 
      num? discountPrice, 
      String? eventImage, 
      String? eventLocation, 
      bool? isLike, 
      bool? isRegistered, // Added new field
      }
      ){
    _id = id;
    _eventName = eventName;
    _totalSeat = totalSeat;
    _currentSeat = currentSeat;
    _eventType = eventType;
    _eventDateAndTime = eventDateAndTime;
    _price = price;
    _discountPrice = discountPrice;
    _eventImage = eventImage;
    _eventLocation = eventLocation;
    _isLike = isLike;
    _isRegistered = isRegistered; // Initialize new field
  }

  WaitingEventData.fromJson(dynamic json) {
    _id = json['id'];
    _eventName = json['event_name'];
    _totalSeat = json['total_seat'];
    _currentSeat = json['current_seat'];
    _eventType = json['event_type'];
    _eventDateAndTime = json['event_date_and_time'];
    _price = json['price'];
    _discountPrice = json['discount_price'];
    _eventImage = json['event_image'];
    _eventLocation = json['event_location'];
    _isLike = json['is_like'];
    _isRegistered = json['is_registered']; // Parse new field from JSON
  }

  num? _id;
  String? _eventName;
  num? _totalSeat;
  num? _currentSeat;
  String? _eventType;
  String? _eventDateAndTime;
  num? _price;
  num? _discountPrice;
  String? _eventImage;
  String? _eventLocation;
  bool? _isLike;
  bool? _isRegistered; // New private field

  WaitingEventData copyWith({
    num? id,
    String? eventName,
    num? totalSeat,
    num? currentSeat,
    String? eventType,
    String? eventDateAndTime,
    num? price,
    num? discountPrice,
    String? eventImage,
    String? eventLocation,
    bool? isLike,
    bool? isRegistered, // Added new field in copyWith
  }) => WaitingEventData(
    id: id ?? _id,
    eventName: eventName ?? _eventName,
    totalSeat: totalSeat ?? _totalSeat,
    currentSeat: currentSeat ?? _currentSeat,
    eventType: eventType ?? _eventType,
    eventDateAndTime: eventDateAndTime ?? _eventDateAndTime,
    price: price ?? _price,
    discountPrice: discountPrice ?? _discountPrice,
    eventImage: eventImage ?? _eventImage,
    eventLocation: eventLocation ?? _eventLocation,
    isLike: isLike ?? _isLike,
    isRegistered: isRegistered ?? _isRegistered, // Handle new field in copyWith
  );

  num? get id => _id;
  String? get eventName => _eventName;
  num? get totalSeat => _totalSeat;
  num? get currentSeat => _currentSeat;
  String? get eventType => _eventType;
  String? get eventDateAndTime => _eventDateAndTime;
  num? get price => _price;
  num? get discountPrice => _discountPrice;
  String? get eventImage => _eventImage;
  String? get eventLocation => _eventLocation;
  bool? get isLike => _isLike;
  bool? get isRegistered => _isRegistered; // Getter for new field

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['event_name'] = _eventName;
    map['total_seat'] = _totalSeat;
    map['current_seat'] = _currentSeat;
    map['event_type'] = _eventType;
    map['event_date_and_time'] = _eventDateAndTime;
    map['price'] = _price;
    map['discount_price'] = _discountPrice;
    map['event_image'] = _eventImage;
    map['event_location'] = _eventLocation;
    map['is_like'] = _isLike;
    map['is_registered'] = _isRegistered; // Added new field to JSON
    return map;
  }
}
