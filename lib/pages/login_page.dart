import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:letmecook/widgets/styled_button.dart';
import 'package:letmecook/widgets/styled_textbox.dart';
import 'package:letmecook/widgets/styled_text.dart';
import 'package:letmecook/assets/themes/app_colors.dart';
import 'package:letmecook/assets/icons/logos.dart';
import 'package:letmecook/pages/login_page.dart';
import 'package:letmecook/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  void forgotPassword() {
    print('Forgot password');
  }

  void logInWithGoogle() {
    print('Log in with Google');
  }

  void logInWithFacebook() {
    print('Log in with Facebook');
  }

  void logInWithTwitter() {
    print('Log in with Twitter');
  }

  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerRepeatPassword =
      TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.dark,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(color: AppColors.dark),
                child: Center(child: Logos.letMeCookLogo),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 325,
                      child: StyledText(
                        text: isLogin ? 'LOG IN' : 'SIGN UP',
                        size: 42,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 325,
                          child: const StyledText(text: 'Email', size: 18),
                        ),
                        Container(
                          width: 325,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: ShapeDecoration(
                            color: AppColors.background,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: StyledTextbox(
                            controller: _controllerEmail,
                            type: 'email',
                          ),
                        ),
                        Container(
                          width: 325,
                          child: const StyledText(text: 'Password', size: 18),
                        ),
                        Container(
                          width: 325,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: ShapeDecoration(
                            color: AppColors.background,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: StyledTextbox(
                            controller: _controllerPassword,
                            type: 'password',
                          ),
                        ),
                        Container(
                          width: 325,
                          alignment: Alignment.centerRight,
                          child: isLogin
                              ? StyledButton(
                                  text: 'Forgot Password?',
                                  buttonStyle: 'text',
                                  onPressed: forgotPassword)
                              : const SizedBox(),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 325,
                          alignment: Alignment.centerLeft,
                          child: StyledText(
                              text: errorMessage == '' ? '' : '$errorMessage',
                              size: 14,
                              color: Colors.red),
                        ),
                      ],
                    ),
                    Container(
                      width: 325,
                      alignment: Alignment.center,
                      child: StyledButton(
                          text: isLogin ? 'Log In' : 'Sign Up',
                          buttonStyle: 'primary',
                          onPressed: isLogin
                              ? signInWithEmailAndPassword
                              : createUserWithEmailAndPassword),
                    ),
                    Container(
                      width: 325,
                      height: 3,
                      color: AppColors.dark,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    Container(
                      width: 325,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StyledButton(
                              icon: Logos.googleLogo,
                              buttonStyle: 'circle',
                              onPressed: logInWithGoogle),
                          StyledButton(
                              icon: Logos.facebookLogo,
                              buttonStyle: 'circle',
                              onPressed: logInWithFacebook),
                          StyledButton(
                              icon: Logos.twitterLogo,
                              buttonStyle: 'circle',
                              onPressed: logInWithTwitter),
                        ],
                      ),
                    ),
                    Container(
                      width: 325,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StyledText(
                              text: isLogin
                                  ? 'Don\'t have an account yet? '
                                  : 'Already have an account? ',
                              size: 18),
                          StyledButton(
                              text: isLogin ? 'Sign up' : 'Log in',
                              buttonStyle: 'text',
                              onPressed: () {
                                setState(() {
                                  errorMessage = '';
                                  isLogin = !isLogin;
                                });
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
