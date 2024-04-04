import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skillswap/Front/candidatefront.dart';
import 'package:skillswap/Front/signup.dart';
import 'package:skillswap/firebase/firebase.dart';
import 'package:skillswap/homepageCandidate/homepage.dart';
import 'package:skillswap/homepageRec/homepagerec.dart';
import 'package:skillswap/widgets/buttons.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  late final Firebase_Service _auth;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late Map<String, dynamic> userdata;
  bool _obscureText = true;
  late RegExp emailValidation;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _auth = Firebase_Service(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(
                  height: height * 0.2,
                ),
                const Text(
                  "SkillSwap",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: height * 0.07,
                ),
                const FormText(text: "Email", alignment: Alignment.centerLeft),
                  CustomTextFormField(width: width*0.9, height: height*0.06, hintText: "abc@gmail.com", controller: _emailController,keyboardType: TextInputType.emailAddress,validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          } ,),
                 
                  const FormText(text: "Password", alignment: Alignment.centerLeft),
          
                  CustomTextFormField(
                    width: width * 0.9,
                    height: height * 0.06,
                    hintText: "********",
                    controller: _passwordController,
                    obscureText: _obscureText,
                    suffixIcon:  IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            // toggle password visibility
                            setState(() {
                              _passwordController.text =
                                  _passwordController.text.replaceAll('•', '');
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                    validator:(value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8 || value.length > 16) {
                          return 'Password must be between 8 and 16 characters long';
                        }
                        return null;
                      }, ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Forget your password?",
                      )),
                ),
                SizedBox(height: height * 0.04),
                ButtonTwo("Log In", Colors.white, Color(0XFF2E307A),width*0.8, height*0.07, 16, () {
                  if (_formKey.currentState!.validate()) {
                    _signIn();
                  }
                }),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(fontSize: 16, color: Color(0XFF7980C2)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF2E307A)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      userdata = await _auth.userData(userId);
    } catch (e) {
      // Handle error
    }
  }

  void _signIn() async {
    String Email = _emailController.text;
    String Password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(Email, Password);

    if (user != null) {
      print(user.uid);
      await _fetchUserData(user.uid);
      print(userdata);
      if (userdata.containsKey('CompanyName')) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomepageREC(user.uid, userdata)),
          (route) => false,
        );
        _showSnackBar("Recruiter is successfully Sign in");
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage(user.uid, userdata)),
          (route) => false,
        );
        _showSnackBar("User is successfully Sign in");
      }
    } else {
      _showSnackBar("Some error happend on Signing in user");
    }
  }
}

