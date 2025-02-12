import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/material/app_colors.dart';
import 'package:train_ticket_booking_system/material/app_icons.dart';
import 'package:train_ticket_booking_system/material/app_styles.dart';
import 'package:train_ticket_booking_system/widget/responsive_widget.dart';
import 'package:train_ticket_booking_system/auth/signupPage.dart';
import 'package:train_ticket_booking_system/pages/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // For form validation
  bool _isPasswordVisible = false;
  bool _isLoading = false; // For loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return; // Validate form first

    setState(() {
      _isLoading = true; // Show loading
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to Home Page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    }

    setState(() {
      _isLoading = false; // Hide loading
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SizedBox(
        height: height,
        width: width,
        child: Row(
          children: [
            // Left Side Banner (Only for large screens)
            ResponsiveWidget.isSmallScreen(context)
                ? const SizedBox()
                : Expanded(
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.lightyellow,
                            AppColors.yellow,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Welcome to Train Ticket Booking System!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darksmoke,
                          ),
                        ),
                      ),
                    ),
                  ),
            // Right Side Login Form
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: height * 0.05),
                color: AppColors.backColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Form(
                    key: _formKey, // Form validation
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.2),
                        Text(
                          ' Log In 👇',
                          style: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darksmoke,
                            fontSize: 25.0,
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'Please enter your login details.',
                          style: ralewayStyle.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        _buildInputField('Email', _emailController,
                            AppIcons.emailIcon, false),
                        SizedBox(height: height * 0.014),
                        _buildInputField('Password', _passwordController,
                            AppIcons.lockIcon, true),
                        SizedBox(height: height * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Don't have an account? Sign Up here",
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
                        SizedBox(height: 20),
                        _buildLoginButton(),
                        SizedBox(height: 20),
                        Center(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              },
                              child: Text(
                                "Continue as a Guest",
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      String icon, bool isPassword) {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label cannot be empty';
              }
              if (label == "Email" && !value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
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
              hintText: 'Enter your $label',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 50.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darksmoke,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginUser,
        // Disable button when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          // Transparent to keep container color
          shadowColor: Colors.transparent,
          // Remove button shadow
          padding: EdgeInsets.zero,
          // No extra padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Match the container
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white) // Loader
            : Text(
                'Log In',
                style: ralewayStyle.copyWith(
                  color: AppColors.yellow,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                ),
              ),
      ),
    );
  }
}
