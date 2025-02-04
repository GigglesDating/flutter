import 'package:shared_preferences/shared_preferences.dart';

import 'user_model.dart';

class SharedPref {
  static SharedPreferences? preferences;

  static Future<void> seStLoginData(UserModel? value) async {
    await preferences?.setString('id', value!.data!.id.toString());
    await preferences?.setString('email', value!.data!.email.toString());
    await preferences?.setString(
        'first_name', value!.data!.firstName.toString());
    await preferences?.setString('last_name', value!.data!.lastName.toString());
    await preferences?.setString('phone', value!.data!.phone.toString());
    await preferences?.setString('gender', value!.data!.gender.toString());
    await preferences?.setString('dob', value!.data!.dob.toString());
    await preferences?.setString('status', value!.data!.status.toString());
    await preferences?.setString(
        'token_detail', value!.data!.tokenDetail.toString());
  }

  String? getTokenDetail() {
    return preferences!.getString('token_detail') ?? '';
  }

   Future<bool> clearUserData() async {
    return await preferences!.clear();
  }

  static Future<String?> eventScreenSave() async {
    await preferences?.setString('lastScreen', 'eventPage');
    return null;
  }

  static Future<String?> digiScreenSave() async {
    await preferences?.setString('lastScreen', 'digiCheck');
    return null;
  }

  static Future<String?> signUpVerifiedScreenSave() async {
    await preferences?.setString('lastScreen', 'signUpVerified');
    return null;
  }

  static Future<String?> otpVerifiedScreen()  async {
    await  preferences?.setString('lastScreen', 'otpVerified');
    return null;
  }

  static String? lastScreen()  {
   return  preferences!.getString('lastScreen');
  }


  static Future<double?> introVideoDuration(double currentPosition) async {
    await preferences?.setDouble('video_position', currentPosition);
    return null;
  }
  static double fetchCurrentPosition() {
    return preferences!.getDouble('video_position') ??0.0;
  }

  static Future<double?> introVideoTotalDuration(double totalDuration) async {
    await preferences?.setDouble('total_duration', totalDuration);
    return null;
  }

  static double fetchTotalDuration() {
    return preferences!.getDouble('total_duration') ??0.0;
  }
}