import 'package:alzaware/home.dart';
import 'package:alzaware/signin.dart';
import 'package:alzaware/splash_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final int appBarSwatchPrimary = 0xff7601c8;

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const MaterialColor appBarSwatch = MaterialColor(
      4278233231,
      <int, Color>{
        50: Color.fromRGBO(
          0,
          168,
          143,
          .1,
        ),
        100: Color.fromRGBO(
          0,
          168,
          143,
          .2,
        ),
        200: Color.fromRGBO(
          0,
          168,
          143,
          .3,
        ),
        300: Color.fromRGBO(
          0,
          168,
          143,
          .4,
        ),
        400: Color.fromRGBO(
          0,
          168,
          143,
          .5,
        ),
        500: Color.fromRGBO(
          0,
          168,
          143,
          .6,
        ),
        600: Color.fromRGBO(
          0,
          168,
          143,
          .7,
        ),
        700: Color.fromRGBO(
          0,
          168,
          143,
          .8,
        ),
        800: Color.fromRGBO(
          0,
          168,
          143,
          .9,
        ),
        900: Color.fromRGBO(
          0,
          168,
          143,
          1,
        ),
      },
    );

    /*const MaterialColor appBarSwatch = MaterialColor(
      4285923784,
      <int, Color>{
        50: Color.fromRGBO(
          118,
          1,
          200,
          .1,
        ),
        100: Color.fromRGBO(
          118,
          1,
          200,
          .2,
        ),
        200: Color.fromRGBO(
          118,
          1,
          200,
          .3,
        ),
        300: Color.fromRGBO(
          118,
          1,
          200,
          .4,
        ),
        400: Color.fromRGBO(
          118,
          1,
          200,
          .5,
        ),
        500: Color.fromRGBO(
          118,
          1,
          200,
          .6,
        ),
        600: Color.fromRGBO(
          118,
          1,
          200,
          .7,
        ),
        700: Color.fromRGBO(
          118,
          1,
          200,
          .8,
        ),
        800: Color.fromRGBO(
          118,
          1,
          200,
          .9,
        ),
        900: Color.fromRGBO(
          118,
          1,
          200,
          1,
        ),
      },
    );*/

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: appBarSwatch,
        fontFamily: GoogleFonts.amarante().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        cardColor: appBarSwatch,
        textTheme: const TextTheme(
          labelLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashView(),
    );
  }
}
