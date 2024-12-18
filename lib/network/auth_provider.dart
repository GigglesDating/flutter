import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/models/customer_support_number_model.dart';
import 'package:giggles/models/event_video.dart';
import 'package:giggles/models/membership_count_model.dart';
import 'package:giggles/models/otp_model.dart';
import 'package:giggles/models/privacy_model.dart';
import 'package:giggles/models/term_model.dart';
import 'package:giggles/models/user_profile_creation_model.dart';
import 'package:giggles/screens/auth/privacy.dart';
import 'package:giggles/screens/auth/privacy.dart';

import '../models/intro_video_model.dart';
import '../models/register_waitng_events_model.dart';
import '../models/user_interests_model.dart';
import '../models/user_model.dart';
import '../models/user_profile_delete_model.dart';
import '../models/waiting_event_model.dart';
import '../models/wating_event_like_model.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String introVideoUrl = '';
  bool _isResendOTPLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  UserModel? _user;
  Otpverify? otpverifyUser;

  String get getIntorVideoUrl => introVideoUrl;

  bool get isLoading => _isLoading;

  bool get isResendOTPLoading => _isResendOTPLoading;

  String get errorMessage => _errorMessage;

  String get successMessage => _successMessage;

  UserModel? get user => _user;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<UserModel?> login(Map<String, dynamic> loginMap) async {
    try {
      // if (_isLoading) return;
      _isLoading = true;
      notifyListeners();
      print("hellooo");
      final userModel = await _authService.login(loginMap);
      print("${userModel!.status}");
      _isLoading = false;
      print('userModel!.detail.toString()');

      if (userModel == null) {
        _errorMessage = userModel!.detail.toString();
      } else {
        _successMessage = userModel.message.toString();
        _user = userModel;
        print('object123');
        print(userModel.data);
        await SharedPref.setLoginData(userModel);
        print(SharedPref().getTokenDetail());
      }
      notifyListeners();
      return userModel;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong';
      notifyListeners();
      return null;
    }
  }

  Future<Otpverify?> otpVerify(Map<String, dynamic> loginMap) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Sending OTP Verify Request: $loginMap');

      final userModel = await _authService.otpverify(loginMap);

      _isLoading = false;
      if (userModel != null && userModel.status == true) {
        _successMessage = userModel.message ?? "OTP Verified Successfully";
        otpverifyUser = userModel;

        // Save details if needed
        print('OTP Verification Successful: ${userModel.toJson()}');
        print('Token: ${SharedPref().getTokenDetail()}');
      } else {
        _errorMessage = userModel?.message ?? 'OTP Verification Failed';
      }

      notifyListeners();
      return userModel;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: $e';
      notifyListeners();
      return null;
    }
  }

  // Future<bool?> otpVerification(Map<String, dynamic> otpMap) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   final otpValidate = await _authService.otpValidate(otpMap);
  //   _isLoading = false;
  //   if (otpValidate == false) {
  //     _errorMessage = 'Enter Valid  OTP';
  //   } else {
  //     _errorMessage = '';
  //     // _user = otpValidate; // Store logged-in user data
  //   }
  //   notifyListeners();
  //   return otpValidate;
  // }

  Future<bool?> postResendOTP() async {
    _isResendOTPLoading = true;
    notifyListeners();
    final otpValidate = await _authService.resendOTP();
    _isResendOTPLoading = false;
    if (otpValidate == false) {
      _errorMessage = 'Enter Valid  OTP';
    } else {
      _errorMessage = '';
      // _user = otpValidate; // Store logged-in user data
    }
    _isResendOTPLoading = false;
    notifyListeners();
    return otpValidate;
  }

  Future<EventVideoModel?> fetchEventVideoData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final fetchIntro = await _authService.fetchEventVideo();

      _isLoading = false;
      print('API Response: ${fetchIntro?.toJson()}'); // Debug the full response
      if (fetchIntro == false) {
        _errorMessage = 'Unable to fetch video';
      } else {
        _errorMessage = '';
      }
      notifyListeners();
      return fetchIntro;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<IntroVideoModel?> fetchIntroVideoData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final fetchIntro = await _authService.fetchIntroVideo();

      _isLoading = false;
      print('API Response: ${fetchIntro?.toJson()}'); // Debug the full response
      if (fetchIntro == false) {
        _errorMessage = 'Unable to fetch video';
      } else {
        _errorMessage = '';
      }
      notifyListeners();
      return fetchIntro;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

//user signup
  Future<UserModel?> signUp(Map<String, dynamic> signUpMap) async {
    try {
      // if (_isLoading) return;
      _isLoading = true;
      notifyListeners();
      final userModel = await _authService.postSignUp(signUpMap);
      _isLoading = false;
      if (userModel?.status == null) {
        _errorMessage = userModel!.detail.toString();
      } else {
        _errorMessage = '';
        _user = userModel;
        await SharedPref.setLoginData(userModel);
      }
      notifyListeners();
      return userModel;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong :$e';
      notifyListeners();
      return null;
    }
  }

  // fetch user interestlist

  Future<UserInterestsModel?> fetchUserInterestList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final fetchUserInterest = await _authService.fetchUserInterest();
      _isLoading = false;
      if (fetchUserInterest == null) {
        _errorMessage = fetchUserInterest!.detail.toString();
      } else {
        _errorMessage = '';
        // _user = otpValidate; // Store logged-in user data
      }
      notifyListeners();
      return fetchUserInterest;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  //  User Profile Creation

  Future<UserProfileCreationModel?> userProfileCreation(
      Map<String, dynamic> userProfileMap,
      List<File> imageFiles,
      List<String> prefrecList,
      List<String> interests) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userProfilecreation = await _authService.postProfileCreationData(
          userProfileMap, imageFiles, prefrecList, interests);
      _isLoading = false;
      if (userProfilecreation == null) {
        _errorMessage = userProfilecreation!.message.toString();
      } else {
        _successMessage = userProfilecreation.message.toString();
        // _user = otpValidate;
      }
      notifyListeners();
      return userProfilecreation;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  //  User Profile Creation

  Future<MembershipCountModel?> membershipCount() async {
    try {
      _isLoading = true;
      notifyListeners();

      final membershipcount = await _authService.fetchMembershipCount();
      _isLoading = false;
      if (membershipcount == null) {
        _errorMessage = membershipcount!.message.toString();
      } else {
        _successMessage = membershipcount.message.toString();
        // _user = otpValidate;
      }
      notifyListeners();
      return membershipcount;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<TermsOfUse?> termsOfUse() async {
    try {
      _isLoading = true;
      notifyListeners();

      final termsOfUse = await _authService.fetchTermsOfUse();
      print("ayush1 ${termsOfUse}");
      _isLoading = false;
      if (termsOfUse == null) {
        _errorMessage = termsOfUse!.message.toString();
      } else {
        _successMessage = termsOfUse.message.toString();
        // _user = otpValidate;
      }
      notifyListeners();
      return termsOfUse;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<PrivacyPolicyModel?> PrivacyPolicy() async {
    try {
      _isLoading = true;
      notifyListeners();

      final termsOfUse = await _authService.fetchPrivacyUse();
      print("ayush1 ${termsOfUse}");
      _isLoading = false;
      if (termsOfUse == null) {
        _errorMessage = termsOfUse!.message.toString();
      } else {
        _successMessage = termsOfUse.message.toString();
        // _user = otpValidate;
      }
      notifyListeners();
      return termsOfUse;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  //  waiting event  list

  Future<WaitingEventModel?> waitingEvents() async {
    try {
      _isLoading = true;
      notifyListeners();

      final membershipcount = await _authService.fetchWaitingEvents();
      _isLoading = false;
      if (membershipcount == null) {
        _errorMessage = membershipcount!.message.toString();
      } else {
        _successMessage = membershipcount.message.toString();
        // _user = otpValidate;
      }
      notifyListeners();
      return membershipcount;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  //  Register to waiting events

  Future<RegisterWaitngEventsModel?> waitingEventRegisterUser(
      Map<String, dynamic> eventMap) async {
    try {
      _isLoading = true;
      notifyListeners();
      final registerForEvents =
          await _authService.registerWaitingEvents(eventMap);
      _isLoading = false;

      print(registerForEvents?.status);
      print(registerForEvents.runtimeType);
      if (registerForEvents?.status == null) {
        _errorMessage = registerForEvents!.detail.toString();
      } else {
        print('registerForEvents.runtimeType');
        print(registerForEvents);
        _successMessage = registerForEvents!.message.toString();

        // _user = otpValidate;
      }
      notifyListeners();
      return registerForEvents;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong';
      notifyListeners();
      return null;
    }
  }

  Future<RegisterWaitngEventsModel?> waitingEventRegisterUser2(
      Map<String, dynamic> eventMap) async {
    try {
      _isLoading = true;
      notifyListeners();
      final registerForEvents =
          await _authService.registerWaitingEvents2(eventMap);
      _isLoading = false;

      print(registerForEvents?.status);
      print(registerForEvents.runtimeType);
      if (registerForEvents?.status == null) {
        _errorMessage = registerForEvents!.detail.toString();
      } else {
        print('registerForEvents.runtimeType');
        print(registerForEvents);
        _successMessage = registerForEvents!.message.toString();

        // _user = otpValidate;
      }
      notifyListeners();
      return registerForEvents;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong';
      notifyListeners();
      return null;
    }
  }

  Future<RegisterWaitngEventsModel?> unRegisterUser(
      Map<String, dynamic> eventMap) async {
    try {
      _isLoading = true;
      notifyListeners();
      final registerForEvents =
          await _authService.registerWaitingEvents(eventMap);
      _isLoading = false;

      print(registerForEvents?.status);
      print(registerForEvents.runtimeType);
      if (registerForEvents?.status == null) {
        _errorMessage = registerForEvents!.detail.toString();
      } else {
        print('registerForEvents.runtimeType');
        print(registerForEvents);
        _successMessage = registerForEvents!.message.toString();

        // _user = otpValidate;
      }
      notifyListeners();
      return registerForEvents;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong';
      notifyListeners();
      return null;
    }
  }
  //  like/disliked to waiting events

  Future<WatingEventLikeModel?> likeWaitingEventsProvider(
      Map<String, dynamic> eventMap) async {
    try {
      _isLoading = true;
      notifyListeners();
      final likeDislikeWaitingEvents =
          await _authService.likeWaitingEvents(eventMap);
      _isLoading = false;

      if (likeDislikeWaitingEvents?.status == null) {
        _errorMessage = likeDislikeWaitingEvents!.detail.toString();
      } else {
        _successMessage = likeDislikeWaitingEvents!.message.toString();
      }
      notifyListeners();
      return likeDislikeWaitingEvents;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong';
      notifyListeners();
      return null;
    }
  }

  // delete user profile
  Future<UserProfileDeleteModel?> deleteUserProfileProvider() async {
    try {
      _isLoading = true;
      notifyListeners();
      final userProfileDelete = await _authService.deleteUserProfile();
      _isLoading = false;
      print('userProfileDelete');
      print(userProfileDelete);
      print(userProfileDelete.runtimeType);

      if (userProfileDelete?.status == null) {
        _errorMessage = userProfileDelete!.detail.toString();
      } else {
        _successMessage = userProfileDelete!.message.toString();
      }
      notifyListeners();
      return userProfileDelete;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong';
      notifyListeners();
      return null;
    }
  }
  //store addhar data to our database

  Future<bool?> postAadharData(Map<String, dynamic> map) async {
    _isLoading = true;
    notifyListeners();
    final otpValidate = await _authService.postAadharDetails(map);
    _isLoading = false;
    if (otpValidate == false) {
      _errorMessage = 'Something went wrong';
    } else {
      _successMessage = 'Aadhar Data Post';
      // _user = otpValidate; // Store logged-in user data
    }
    _isLoading = false;
    notifyListeners();
    return otpValidate;
  }


  // customer support number


  Future<CustomerSupportNumberModel?> getCustomerSupportNumber() async {
    _isLoading = true;
    notifyListeners();
    final customerSupport = await _authService.fetchCustomerSupportNumber();
    _isLoading = false;
    if (customerSupport == false) {
      _errorMessage = 'Something went wrong';
    } else {
      _successMessage = customerSupport.message.toString();
      // _user = otpValidate; // Store logged-in user data
    }
    _isLoading = false;
    notifyListeners();
    return customerSupport;
  }
}
