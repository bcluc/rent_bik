import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rent_bik/components/password_text_field.dart';
import 'package:rent_bik/screens/auth/login_view.dart';
import 'package:rent_bik/screens/bike_rental_management.dart';
import 'package:rent_bik/screens/customer_manage/add_edit_customer_form.dart';

import '../../utils/common_variables.dart';

class LoginLayout extends StatefulWidget {
  const LoginLayout({super.key});

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout> {
  final _pageController = PageController();
  double _pageIndex = 0;
  bool _isProcessing = false;
  String _errorText = '';

  final _passwordController = TextEditingController();
  void _submit() async {
    // check
    final enteredPassword = _passwordController.text;

    _errorText = '';
    if (enteredPassword.isEmpty) {
      _errorText = 'Bạn chưa nhập Mật khẩu';
    } else if (enteredPassword.length < 6) {
      _errorText = 'Mật khẩu có ít nhất 6 ký tự';
    }

    if (_errorText.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    if (enteredPassword == "123456") {
      await Future.delayed(
        const Duration(milliseconds: 400),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đăng nhập thành công.',
              textAlign: TextAlign.center,
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            width: 300,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const BikeRentalManagement(),
            //child: const AddEditCustomerForm(),
            duration: const Duration(milliseconds: 300),
          ),
          (route) => false,
        );
      }
    } else {
      _errorText = 'Tên đăng nhập hoặc mật khẩu không đúng';

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/loginCover.png'),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  '@devTEAM',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const Gap(14),
              PasswordTextField(
                passwordController: _passwordController,
                onEditingComplete: _submit,
              ),
              const Gap(10),
              Text(
                _errorText,
                style: errorTextStyle(context),
              ),
              const Gap(12),
              _isProcessing
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 35),
                        foregroundColor: Colors.white,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the value according to your preference
                        ),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}
