import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:train_ticket_booking_system/auth/signinPage.dart';
import 'package:train_ticket_booking_system/material/app_colors.dart';
import 'package:train_ticket_booking_system/material/app_icons.dart';
import 'package:train_ticket_booking_system/material/app_styles.dart';
import 'package:train_ticket_booking_system/material/app_images.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // For showing loading state

  @override
  void dispose() {
    _email.dispose();
    _fullname.dispose();
    _phoneNumber.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (_fullname.text.isEmpty ||
        _address.text.isEmpty ||
        _phoneNumber.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill in all fields.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Authentication Sign-Up
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      // Firestore User Data
      await FirebaseFirestore.instance
          .collection('customer')
          .doc(userCredential.user!.uid)
          .set({
        'cFullname': _fullname.text.trim(),
        'cAddress': _address.text.trim(),
        'cPhoneNum': _phoneNumber.text.trim(),
        'cEmail': _email.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Success Message
      Fluttertoast.showToast(msg: "Account created successfully!");

      // Navigate to Sign-In Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password should be at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email.";
      } else {
        errorMessage = "Sign-up failed: ${e.message}";
      }
      Fluttertoast.showToast(msg: errorMessage);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Logo
            Container(
              height: height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.lightyellow, AppColors.yellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Image.asset(
                  AppImages.trainlogo,
                  height: height * 0.15,
                ),
              ),
            ),

            // Form Section
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: width * 0.15, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Sign Up',
                      style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darksmoke,
                        fontSize: 35.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Please enter your details.',
                      textAlign: TextAlign.center,
                      style: ralewayStyle.copyWith(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darksmoke,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInputField('Full Name', _fullname, AppIcons.fullname, false),
                  SizedBox(height: 14),
                  _buildInputField('Address', _address, AppIcons.location, false),
                  SizedBox(height: 14),
                  _buildInputField(
                      'Phone Number', _phoneNumber, AppIcons.phonenumber, false),
                  SizedBox(height: 14),
                  _buildInputField('Email', _email, AppIcons.emailIcon, false),
                  SizedBox(height: 14),
                  _buildInputField('Password', _password, AppIcons.lockIcon, true),
                  SizedBox(height: 40),

                  _buildSignUpButton(),
                  SizedBox(height: 20),

                  Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          "Have an account already? Sign in",
                          style: ralewayStyle.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darksmoke,
                            decoration: TextDecoration.underline,
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
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String icon, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            label,
            style: ralewayStyle.copyWith(
              fontSize: 12.0,
              color: AppColors.darksmoke,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: AppColors.whiteColor,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            style: ralewayStyle.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.darksmoke,
              fontSize: 12.0,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: IconButton(
                onPressed: () {},
                icon: Image.asset(icon),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Image.asset(
                  _isPasswordVisible
                      ? 'assets/icons/view.png'
                      : 'assets/icons/hide.png',
                ),
              )
                  : null,
              contentPadding: const EdgeInsets.only(top: 16.0),
              hintText: 'Enter $label',
              hintStyle: ralewayStyle.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.darksmoke.withOpacity(0.5),
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _registerUser,
      child: Container(
        height: 50.0,
        width: 250,
        decoration: BoxDecoration(
          color: AppColors.darksmoke,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(color: AppColors.yellow)
              : Text(
            'Sign Up',
            style: ralewayStyle.copyWith(
              color: AppColors.yellow,
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }
}
