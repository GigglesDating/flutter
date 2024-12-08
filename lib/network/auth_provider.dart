import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:giggles/constants/database/shared_preferences_service.dart';
import 'package:giggles/models/membership_count_model.dart';
import 'package:giggles/models/user_profile_creation_model.dart';

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
      final userModel = await _authService.login(loginMap);
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

  Future<bool?> otpVerification(Map<String, dynamic> otpMap) async {
    _isLoading = true;
    notifyListeners();
    final otpValidate = await _authService.otpValidate(otpMap);
    _isLoading = false;
    if (otpValidate == false) {
      _errorMessage = 'Enter Valid  OTP';
    } else {
      _errorMessage = '';
      // _user = otpValidate; // Store logged-in user data
    }
    notifyListeners();
    return otpValidate;
  }

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

  Future<IntroVideoModel?> fetchIntroVideoData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final fetchIntro = await _authService.fetchIntroVideo();
      _isLoading = false;
      print('otpValidate');
      print(fetchIntro);
      print(fetchIntro.runtimeType);
      if (fetchIntro == false) {
        _errorMessage = 'Unable to fetch video';
      } else {
        _errorMessage = '';
        // _user = otpValidate; // Store logged-in user data
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
      Map<String, dynamic> userProfileMap,List<File> imageFiles ,List<String> prefrecList,List<String> interests) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userProfilecreation =
          await _authService.postProfileCreationData(userProfileMap,imageFiles,prefrecList,interests);
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
  Future<UserProfileDeleteModel?> deleteUserProfileProvider(
    ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final userProfileDelete =
          await _authService.deleteUserProfile();
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

  Future<bool?> postAadharData(Map<String,dynamic> map) async {
    _isLoading = true;
    notifyListeners();
    final otpValidate = await _authService.postAadharDetails(map);
    _isLoading = false;
    if (otpValidate == false) {
      _errorMessage = 'Enter Valid  OTP';
    } else {
      _successMessage = 'Aadhar Data Post';
      // _user = otpValidate; // Store logged-in user data
    }
    _isLoading = false;
    notifyListeners();
    return otpValidate;
  }

}
