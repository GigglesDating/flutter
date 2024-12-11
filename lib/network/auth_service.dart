import 'dart:convert';
import 'dart:io';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/constants/url_helpers.dart';
import 'package:giggles/models/event_video.dart';
import 'package:giggles/models/membership_count_model.dart';
import 'package:giggles/models/otp_model.dart';
import 'package:giggles/models/privacy_model.dart';
import 'package:giggles/models/term_model.dart';
import 'package:giggles/models/user_interests_model.dart';
import 'package:giggles/models/user_profile_creation_model.dart';
import 'package:giggles/screens/auth/privacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/intro_video_model.dart';
import '../models/register_waitng_events_model.dart';
import '../models/user_model.dart';
import '../models/user_profile_delete_model.dart';
import '../models/waiting_event_model.dart';
import '../models/wating_event_like_model.dart';

class AuthService {
  String baseUrl = UrlHelper.baseUrl;
  String _introVideoUrl = '';
  String get introVideoUrl => _introVideoUrl;
  // SharedPref sharedPref =SharedPref();

  var headerWithToken = {
    'Authorization': 'Token ${SharedPref().getTokenDetail()}',
    // 'Authorization': 'Token 4e51ea3422c5580ce41952ab9b8c9b222cb3dd3c',
    'Content-Type': 'application/json'
  };

  Future<Otpverify?> otpverify(Map<String, dynamic> loginMap) async {
    final url = Uri.parse(baseUrl + UrlHelper.otpVerificationUrl);

    try {
      final response = await http.post(
        url,
        body: jsonEncode(loginMap),
        headers: {
          'Authorization': 'Token ${SharedPref().getTokenDetail()}',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save the last screen for navigation tracking
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastScreen', 'otpVerified');

        return Otpverify.fromJson(responseData);
      } else {
        print('Error in OTP Verify API: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in OTP Verify API: $e');
      return null;
    }
  }

  Future<UserModel?> login(Map<String, dynamic> loginMap) async {
    final url = Uri.parse(baseUrl + UrlHelper.loginUrl);
    final response = await http.post(
      url,
      body: jsonEncode(loginMap),
      headers: {'Content-Type': 'application/json'},
    );

    print('response.statusCode');
    print(response.statusCode);
    print(response.body);
    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      print("qwerty ${responseData["token_detail"]}");
      await prefs.setString(
        "userToken",
        responseData["token_detail"].toString(),
      );
      await prefs.setString(
        "isUser",
        responseData["status"].toString(),
      );
      // await prefs.setString('lastScreen', 'otpVerified'); //important
      // await SharedPref.setLoginData(jsonDecode(response.body));
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      return null; // Login failed
    }
  }

  Future<bool?> otpValidate(Map<String, dynamic> loginMap) async {
    final url = Uri.parse(baseUrl + UrlHelper.otpVerificationUrl);
    final response = await http.post(
      url,
      body: jsonEncode(loginMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    print('response.verufy');
    print(response.statusCode);
    print(response.body);
    print(headerWithToken);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false; // Login failed
    }
  }

  Future<bool?> resendOTP() async {
    final url = Uri.parse(baseUrl + UrlHelper.resendOTPUrl);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    print('response.resend');
    print(response.statusCode);
    print(response.body);
    print(headerWithToken);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false; // Login failed
    }
  }

  Future<IntroVideoModel> fetchIntroVideo() async {
    final url = Uri.parse(baseUrl + (UrlHelper.introVideoUrl));
    final response = await http.get(
      url,
      // body: jsonEncode(loginMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print("qwerty ${SharedPref().getTokenDetail()}");
      print("vvvvvvvvv ${response.statusCode}");
      return IntroVideoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video URL');
    }
  }

  Future<EventVideoModel> fetchEventVideo() async {
    final url = Uri.parse(baseUrl + (UrlHelper.eventVideoUrl));
    final response = await http.get(
      url,
      // body: jsonEncode(loginMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print("qwerty ${SharedPref().getTokenDetail()}");
      print("vvvvvvvvv ${response.statusCode}");
      return EventVideoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video URL');
    }
  }

  Future<UserModel?> postSignUp(Map<String, dynamic> signupMap) async {
    UserModel userModel = UserModel();
    final url = Uri.parse(baseUrl + UrlHelper.signUpUrl);
    final response = await http.post(
      url,
      body: jsonEncode(signupMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print("heyyy ${response.statusCode}");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastScreen', 'signUpVerified');
      return UserModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exc /eption('11111');
    }
  }

  // fetch User interest list
  Future<UserInterestsModel?> fetchUserInterest() async {
    UserInterestsModel userModel = UserInterestsModel();
    final url = Uri.parse(baseUrl + UrlHelper.userInterrestUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    print('response.statusCode');
    print(response.statusCode);
    print(response.body);
    print(response.body);
    if (response.statusCode == 200) {
      return UserInterestsModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  // User Profile Creation
  Future<UserProfileCreationModel?> postProfileCreationData(
      Map<String, dynamic> profileCreationMap,
      List<File> imageFiles,
      List<String> prefrecList,
      List<String> interests) async {
    UserProfileCreationModel userModel = UserProfileCreationModel();
    final url = Uri.parse(baseUrl + UrlHelper.userProfileUrl);
    // final response = await http.post(
    //   url,
    //   body: jsonEncode(profileCreationMap),
    //   headers: headerWithToken,
    // );
    var request = http.MultipartRequest(
        'POST', Uri.parse(baseUrl + UrlHelper.userProfileUrl))
      ..headers.addAll(
        {
          'Authorization': 'Token ${SharedPref().getTokenDetail()}',
          'Content-Type': 'application/json'
        },
      );

    profileCreationMap
        .forEach((k, v) => request.fields[k] = v.toString() ?? "");
    // String preferenceListjson = jsonEncode();

    // List<String> myList = ["Companionship", "Relationship"];
    // String listString = myList.map((e) => '"$e"').join(', ');

    print('object');

    print('[$prefrecList]');
    String result = prefrecList.join(', ');
    if (prefrecList.isNotEmpty) {
      // for (var preference in prefrecList) {

      // request.fields['dating_preferencesq'] = result;

      // }
      request.files.add(
          await http.MultipartFile.fromString("dating_preferencesq", result));
    }
    if (interests.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromString(
          "interests", jsonEncode(interests)));
    }
    if (imageFiles.isNotEmpty) {
      for (var file in imageFiles) {
        var multipartFile = await http.MultipartFile.fromPath(
          "images", // Key name expected by the backend
          file.path,
        );
        request.files.add(multipartFile);
      }
      // request.files.add(await http.MultipartFile.fromPath("images", imageFiles));
    }
    final response = await http.Response.fromStream(await request.send());
    print('12121');
    print(profileCreationMap);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return UserProfileCreationModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  // Fetech Membership Count
  Future<MembershipCountModel?> fetchMembershipCount() async {
    MembershipCountModel userModel = MembershipCountModel();
    final url = Uri.parse(baseUrl + UrlHelper.membershipCountUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return MembershipCountModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      // userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      // userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  Future<TermsOfUse?> fetchTermsOfUse() async {
    TermsOfUse userModel = TermsOfUse();
    final url = Uri.parse(baseUrl + UrlHelper.termsAndConditions);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print("ayush ${response.statusCode}");
      return TermsOfUse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      print("ayush ${response.statusCode}");
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      print("ayush ${response.statusCode}");
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  Future<PrivacyPolicyModel?> fetchPrivacyUse() async {
    PrivacyPolicyModel userModel = PrivacyPolicyModel();
    final url = Uri.parse(baseUrl + UrlHelper.privacyPolicy);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print("ayush ${response.statusCode}");
      return PrivacyPolicyModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      print("ayush ${response.statusCode}");
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      print("ayush ${response.statusCode}");
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  Future<TermsOfUse?> fetchPrivacyOfUse() async {
    TermsOfUse userModel = TermsOfUse();
    final url = Uri.parse(baseUrl + UrlHelper.termsAndConditions);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print("ayush ${response.statusCode}");
      return TermsOfUse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      print("ayush ${response.statusCode}");
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      print("ayush ${response.statusCode}");
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  // Fetech Waiting List Events
  Future<WaitingEventModel?> fetchWaitingEvents() async {
    WaitingEventModel userModel = WaitingEventModel();
    final url = Uri.parse(baseUrl + UrlHelper.waitingEventUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return WaitingEventModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  // Register  Waiting list Events
  Future<RegisterWaitngEventsModel?> registerWaitingEvents(
      Map<String, dynamic> eventMap) async {
    RegisterWaitngEventsModel userModel = RegisterWaitngEventsModel();
    final url = Uri.parse(baseUrl + UrlHelper.waitingEventUrl);
    final response = await http.post(
      url,
      body: jsonEncode(eventMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print(" ayush123 ${response.statusCode}");
      return RegisterWaitngEventsModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  Future<RegisterWaitngEventsModel?> registerWaitingEvents2(
      Map<String, dynamic> eventMap) async {
    RegisterWaitngEventsModel userModel = RegisterWaitngEventsModel();
    final url = Uri.parse(baseUrl + UrlHelper.waitingEventUrl);
    final response = await http.delete(
      url,
      body: jsonEncode(eventMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      print("ayush123 ${response.statusCode}");
      return RegisterWaitngEventsModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  Future<WatingEventLikeModel?> likeWaitingEvents(
      Map<String, dynamic> eventMap) async {
    WatingEventLikeModel userModel = WatingEventLikeModel();
    final url = Uri.parse(baseUrl + UrlHelper.likeWaitingEventUrl);
    final response = await http.post(
      url,
      body: jsonEncode(eventMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return WatingEventLikeModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  Future<UserProfileDeleteModel?> deleteUserProfile() async {
    UserProfileDeleteModel userModel = UserProfileDeleteModel();
    final url = Uri.parse(baseUrl + UrlHelper.userProfileUrl);
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return UserProfileDeleteModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 404) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else if (response.statusCode == 500) {
      userModel.detail = jsonDecode(response.body)['message'];
      return userModel;
    } else {
      return null;
      // throw Exception('11111');
    }
  }

  //aadhar data post ehich fetch from  hyper verge sdk

  Future<bool?> postAadharDetails(Map<String, dynamic> adharMap) async {
    final url = Uri.parse(baseUrl + UrlHelper.adharDataUrl);
    final response = await http.post(
      url,
      body: jsonEncode(adharMap),
      headers: {
        'Authorization': 'Token ${SharedPref().getTokenDetail()}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false; // Login failed
    }
  }
}
