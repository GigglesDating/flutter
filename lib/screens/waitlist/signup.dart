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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

            // Overlay Container
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDarkMode
                          ? Colors.black.withAlpha(80)
                          : Colors.white.withAlpha(80),
                      isDarkMode
                          ? Colors.black.withAlpha(80)
                          : Colors.white.withAlpha(80),
                    ],
                  ),
                ),
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
                      Form(
                        key: _formKey,
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
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your first name';
                                        }
                                        return null;
                                      },
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
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your last name';
                                        }
                                        return null;
                                      },
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
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        return null;
                                      },
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
                                  onPressed: _isLoading ? null : _handleSignup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
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

  Future<void> _handleSignup() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);

    try {
      // Get UUID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('uuid');

      if (uuid == null) {
        throw Exception('User ID not found. Please try logging in again.');
      }

      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.signup(
        uuid: uuid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dob: DateFormat('yyyy-MM-dd').format(_birthday!),
        email: _emailController.text.trim(),
        gender: _gender!,
        city: _city!,
        consent: _agreeToTerms,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        // Save registration status
        await prefs.setString('reg_process', 'reg_started');

        if (!mounted) return;

        // Navigate to KYC screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const KycConsentScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Signup failed. Please try again.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during signup: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
