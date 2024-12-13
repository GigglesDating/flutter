import 'package:giggles/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? preferences;
  static Future<void> setLoginData(UserModel? value) async {
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

  static Future<void> eventScreenSave() async {
    await preferences?.setString('lastScreen', 'eventPage');
  }

  static Future<void> digiScreenSave() async {
    await preferences?.setString('lastScreen', 'digiCheck');
  }

  static Future<void> signUpVerifiedScreenSave() async {
    await preferences?.setString('lastScreen', 'signUpVerified');
  }

  static Future<void> otpVerifiedScreen() async {
    await preferences?.setString('lastScreen', 'otpVerified');
  }
}
