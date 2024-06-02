import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rent_bik/components/password_text_field.dart';
import 'package:rent_bik/screens/bike_rental_management.dart';

import '../../utils/common_variables.dart';

class LoginLayout extends StatefulWidget {
  const LoginLayout({super.key});

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout> {
  bool _isProcessing = false;
  String _errorText = '';

  final _passwordController = TextEditingController();
  void _submit() async {
    // List<XeDTO> xes = await dbProcess.queryXeDto();
    // print('\n\n\n');
    // print(xes.first.dongXes.first.maDongXe);
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
  void initState() {
    super.initState();
    //fetchData();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/loginCover.png'),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 100,
                          child: Image.asset(
                            'assets/logo/textLogo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Gap(100),
                    Image.asset(
                      'assets/images/carDisplay.png',
                      fit: BoxFit.contain,
                    ),
                    const Gap(100),
                  ],
                ),
              ),
              const Gap(24),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      child: Text("Xin chào",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start),
                    ),
                    const Gap(10),
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
                        : SizedBox(
                            width: double.infinity,
                            child: TextButton(
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
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
