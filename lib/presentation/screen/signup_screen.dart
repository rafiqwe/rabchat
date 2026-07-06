
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabchats/core/common/custom_button.dart';
import 'package:rabchats/core/common/custom_text_field.dart';
import 'package:rabchats/core/utils/ui_utils.dart';
import 'package:rabchats/data/services/service_loactor.dart';
import 'package:rabchats/logic/cubit/auth_cubit.dart';
import 'package:rabchats/logic/cubit/auth_state.dart';
import 'package:rabchats/presentation/home/home_screen.dart';
import 'package:rabchats/router/app_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  bool _isPasswordVisible = false;

  final _nameFocus = FocusNode();
  final _userNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    userNameController.dispose();
    nameController.dispose();

    _emailFocus.dispose();
    _nameFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    _userNameFocus.dispose();

    super.dispose();
  }

  String? _validatedUserName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Username";
    }
    return null;
  }

  String? _validatedPhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Phone number";
    }

    // Matches optional +, followed by 7 to 15 digits (allowing spaces, dashes, and parentheses)
    final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{11,13}$');

    if (!phoneRegex.hasMatch(value)) {
      return "Please enter a valid phone number";
    }
    return null;
  }

  String? _validatedEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Email";
    }

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    // Check if the input text matches the regex pattern
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid Email address";
    }
    return null;
  }

  String? _validatedPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  String? _validatedName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Full Name";
    }
    return null;
  }

  Future<void> handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (_formkey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signUp(
          username: userNameController.text,
          fullName: nameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showSnackBar(
            context,
            message: state.error.toString(),
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Please fill in the details to continue ',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Full Name',
                      validator: _validatedName,
                      focusNode: _nameFocus,
                      prefixIcons: Icon(Icons.person_outlined),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: userNameController,
                      hintText: 'Username',
                      prefixIcons: Icon(Icons.alternate_email_outlined),
                      validator: _validatedUserName,
                      focusNode: _userNameFocus,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Phone Number',
                      prefixIcons: Icon(Icons.phone_outlined),
                      validator: _validatedPhone,
                      focusNode: _phoneFocus,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      prefixIcons: Icon(Icons.email_outlined),
                      validator: _validatedEmail,
                      focusNode: _emailFocus,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: !_isPasswordVisible,
                      suffixIcons: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: _isPasswordVisible == false
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined),
                      ),
                      prefixIcons: Icon(Icons.lock_outline),
                      validator: _validatedPassword,
                      focusNode: _passwordFocus,
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      onPressed: handleSubmit,
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "If you have an account?  ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  getIt<AppRouter>().pop(SignupScreen());
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
