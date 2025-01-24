import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import '../../network/think.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../barrel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _birthday;
  String? _gender;
  String? _city;
  bool _agreeToTerms = false;
  String? _uuid;

  @override
  void initState() {
    super.initState();
    _loadUuid();
  }

  Future<void> _loadUuid() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('user_uuid');
    if (uuid != null) {
      setState(() {
        _uuid = uuid;
      });
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // Responsive calculations
    final logoSize = (size.width * 0.4).clamp(160.0, 240.0);
    final horizontalPadding = size.width * 0.06;
    final fieldSpacing = size.width * 0.03;
    final verticalSpacing = size.height * 0.02;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withAlpha(26),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isIOS ? 16 : 14,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withAlpha(230),
        fontWeight: FontWeight.w500,
      ),
    );

    final topPadding = size.height * 0.12;
    final logoTopMargin = size.height * 0.02;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                isDarkMode
                    ? 'assets/dark/bgs/signupbg.png'
                    : 'assets/light/bgs/signupbg.png',
                fit: BoxFit.cover,
              ),
            ),

            // Content
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: size.height -
                        (MediaQuery.of(context).padding.top +
                            MediaQuery.of(context).padding.bottom),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    bottomInset + verticalSpacing,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Section
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                          top: logoTopMargin,
                          bottom: verticalSpacing * 6,
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              padding: EdgeInsets.all(logoSize * 0.2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(15),
                                border: Border.all(
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Image.asset(
                                isDarkMode
                                    ? 'assets/light/favicon.png'
                                    : 'assets/dark/favicon.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Form Section
                      Container(
                        margin: EdgeInsets.only(
                            top: verticalSpacing * 2, bottom: verticalSpacing),
                        child: Column(
                          children: [
                            // Names Row
                            Row(
                              children: [
                                Expanded(
                                  child: glassContainer(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: inputDecoration.copyWith(
                                        hintText: 'First Name',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: fieldSpacing),
                                Expanded(
                                  child: glassContainer(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: inputDecoration.copyWith(
                                        hintText: 'Last Name',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: verticalSpacing),

                            // Email and Gender Row
                            Row(
                              children: [
                                Expanded(
                                  flex: 60,
                                  child: glassContainer(
                                    child: TextFormField(
                                      controller: _emailController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: inputDecoration.copyWith(
                                        hintText: 'E-mail',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: fieldSpacing),
                                Expanded(
                                  flex: 40,
                                  child: glassContainer(
                                    child: DropdownButtonFormField<String>(
                                      value: _gender,
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      icon: const SizedBox.shrink(),
                                      dropdownColor:
                                          Colors.black.withAlpha(204),
                                      decoration: inputDecoration.copyWith(
                                          hintText: 'Gender',
                                          hintStyle: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 2, 2, 2))
                                          // suffixIcon: const Icon(
                                          //   Icons.arrow_drop_down,
                                          //   color: Colors.white,
                                          // ),
                                          ),
                                      items: ['Male', 'Female', 'Other']
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (value) =>
                                          setState(() => _gender = value),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: verticalSpacing),

                            // Birthday and City Row
                            Row(
                              children: [
                                Expanded(
                                  child: glassContainer(
                                    child: InkWell(
                                      onTap: _selectDate,
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: isIOS ? 16 : 14,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _birthday == null
                                                    ? 'Birthday'
                                                    : DateFormat('dd/MM/yyyy')
                                                        .format(_birthday!),
                                                style: TextStyle(
                                                  color: Colors.white.withAlpha(
                                                      _birthday == null
                                                          ? 230
                                                          : 255),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.calendar_today,
                                                color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: fieldSpacing),
                                Expanded(
                                  child: glassContainer(
                                    child: DropdownButtonFormField<String>(
                                      value: _city,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      dropdownColor:
                                          Colors.black.withAlpha(204),
                                      decoration: inputDecoration.copyWith(
                                        hintText: 'City',
                                        suffixIcon: const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                        ),
                                      ),
                                      items: [
                                        'Bangalore',
                                        'Mumbai',
                                        'Delhi',
                                        'Chennai'
                                      ]
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (value) =>
                                          setState(() => _city = value),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bottom Section
                      Container(
                        margin: EdgeInsets.only(top: verticalSpacing),
                        child: Column(
                          children: [
                            // Terms Row
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                    offset: const Offset(0, 2),
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      onChanged: (value) => setState(
                                          () => _agreeToTerms = value ?? false),
                                      fillColor:
                                          WidgetStateProperty.resolveWith(
                                        (states) => states
                                                .contains(WidgetState.selected)
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.white,
                                            height: 1.5,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          children: [
                                            const TextSpan(
                                                text: 'I have read '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  // Handle Privacy Policy tap
                                                },
                                            ),
                                            const TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Terms and Conditions',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  // Handle Terms tap
                                                },
                                            ),
                                            const TextSpan(
                                              text:
                                                  '. I consent to verify myself with Aadhar',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 1.5),

                            // Join Button
                            Center(
                              child: SizedBox(
                                width: size.width * 0.5,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'SUBMIT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() {
    final now = DateTime.now();
    final minAge = now.subtract(const Duration(days: 365 * 100)); // Max age 100
    final maxAge = now.subtract(const Duration(days: 365 * 18)); // Min age 18

    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: minAge,
      maxTime: maxAge, // Set to 18 years ago
      onConfirm: (date) {
        setState(() {
          _birthday = date;
        });
      },
      theme: picker.DatePickerTheme(
        containerHeight: 210.0,
        titleHeight: 44.0,
        itemHeight: 40.0,
        backgroundColor: Colors.black.withAlpha(230),
        headerColor: const Color.fromARGB(255, 0, 0, 0),
        itemStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        doneStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        cancelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      locale: picker.LocaleType.en,
    );
  }

  void _submitForm() async {
    if (_uuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AadharStatusScreen(),
          ));
    }

    if (!_validateFields()) return;

    try {
      final thinkProvider = ThinkProvider();

      final response = await thinkProvider.signup(
        uuid: _uuid!,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        dob: DateFormat('yyyy-MM-dd').format(_birthday!),
        gender: _gender!,
        city: _city!,
        consent: _agreeToTerms,
      );

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully registered!')),
          );
          // Navigate based on the registration flow
          // The backend will return reg_status: 'reg_started'
          // This means the user needs to complete Aadhar verification next
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Registration failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  bool _validateFields() {
    // Check if form is valid
    if (!_formKey.currentState!.validate()) return false;

    // Birthday validation
    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birthday')),
      );
      return false;
    }

    // Age validation (18+)
    final age = DateTime.now().difference(_birthday!).inDays / 365;
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be 18 or older to register')),
      );
      return false;
    }

    // Gender validation
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return false;
    }

    // Terms validation
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return false;
    }

    // City validation
    if (_city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your city')),
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withAlpha(51),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
