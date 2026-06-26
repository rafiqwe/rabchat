import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rabchats/core/common/custom_button.dart';
import 'package:rabchats/core/common/custom_text_field.dart';
import 'package:rabchats/pressentation/screen/login_screen.dart';

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

  String? _validatedUserName(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your Username";
    }
    return null;

  }

  String? _validatedPhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Phone number";
    }

    // Matches optional +, followed by 7 to 15 digits (allowing spaces, dashes, and parentheses)
    final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{7,15}$');

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
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    );

    // Check if the input text matches the regex pattern
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid Email address";
    }
    return null;

  }

  String? _validatedPassword(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your Password";
    }
    if(value.length < 6 ){
      return "Password must be at least 6 characters long";
    }
    return null;
  }
  String? _validatedName(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your Full Name";
    }
    return null;

  }

  @override
  Widget build(BuildContext context) {
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                  suffixIcons: IconButton(onPressed: (){
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  }, icon: _isPasswordVisible == false ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined)),
                  prefixIcons: Icon(Icons.lock_outline),
                  validator: _validatedPassword,
                  focusNode: _passwordFocus,
                ),
                const SizedBox(height: 30),
                CustomButton(onPressed: () {
                  FocusScope.of(context).unfocus();
                  if(_formkey.currentState?.validate() ?? false){
                  }
                }, text: 'Sign Up'),
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
                              Navigator.pop(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
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
  }
}
