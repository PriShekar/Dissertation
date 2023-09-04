import 'package:alzaware/Basic%20Resources/LoadingWidget.dart';
import 'package:alzaware/home.dart';
import 'package:alzaware/signup.dart';
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';

class SignInAlzAware extends StatefulWidget {
  const SignInAlzAware({Key? key}) : super(key: key);

  @override
  State<SignInAlzAware> createState() => _SignInAlzAwareState();
}

class _SignInAlzAwareState extends State<SignInAlzAware> {
  String emailVal = "", passwordVal = "";
  bool signingIn = false;

  void signInUser() {
    final auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(email: emailVal, password: passwordVal)
        .then((result) {
      signingIn = false;
      setState(() {});
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeAlzAware(result.user!.uid)),
          (route) => false);
    }).catchError((error) {
      String errorType = error.toString().substring(15);
      if (errorType.startsWith("user")) {
        errorType = "User not found, please sign up!";
      } else if (errorType.startsWith("wrong")) {
        errorType = "Please enter correct password!";
      } else if (errorType.startsWith("too-many")) {
        errorType = "Too many login requests, try again later!";
      }
      Toast.show(errorType,
          textStyle: const TextStyle(
            color: Colors.red,
          ),
          backgroundColor: Colors.white,
          duration: Toast.lengthLong);
      signingIn = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      body: !signingIn
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 200,
                  child: Image(
                    image: AssetImage("assets/images/alzawarelogo.png"),
                  ),
                ),
                Text(
                  "Alzhemist",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    decoration: InputDecoration(
                      hintText: "Phone number/Email address",
                      hintStyle:
                          const TextStyle(color: Colors.black, fontSize: 18),
                      // filled: true,
                      // fillColor: Colors.grey,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.black45,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.black45,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onChanged: (val) {
                      emailVal = val;
                      setState(() {});
                    },
                    cursorColor: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    obscureText: true,
                    onChanged: (val) {
                      passwordVal = val;
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle:
                          const TextStyle(color: Colors.black, fontSize: 18),
                      // filled: true,
                      // fillColor: Colors.grey,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.black45,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.black45,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    cursorColor: Colors.white,
                    onSubmitted: (term) {
                      signingIn = true;
                      setState(() {});
                      signInUser();
                      //Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeAlzAware()));
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showResetPasswordDialog();
                    },
                    child: const Text("Forget Password?"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            )
          : LoadingWidget("Signing In"),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpAlzAware()));
              },
              child: Text(
                "Create a new account",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResetPasswordDialog();
      },
    );
  }
}

class ResetPasswordDialog extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ResetPasswordDialog({super.key});

  Future<void> _resetPassword(BuildContext context) async {
    String email = _emailController.text;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Toast.show("Password reset email sent to: $email",
          textStyle: const TextStyle(
            color: Colors.red,
          ),
          backgroundColor: Colors.white,
          duration: Toast.lengthLong);
    } catch (error) {
      Toast.show("Something went wrong please check your email: $email",
          textStyle: const TextStyle(
            color: Colors.red,
          ),
          backgroundColor: Colors.white,
          duration: Toast.lengthLong);
      print('Error sending password reset email: $error');
      // You can display an error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            textAlign: TextAlign.center,
            controller: _emailController,
            style: const TextStyle(color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
              hintText: "Email",
              hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
              // filled: true,
              // fillColor: Colors.grey,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.black45,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.black45,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            cursorColor: Colors.white,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _resetPassword(context);
            Navigator.pop(context);
          },
          child: const Text('Reset Password'),
        ),
      ],
    );
  }
}
