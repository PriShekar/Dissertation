import 'package:alzaware/Basic%20Resources/LoadingWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toast/toast.dart';

class SignUpAlzAware extends StatefulWidget {
  const SignUpAlzAware({Key? key}) : super(key: key);

  @override
  State<SignUpAlzAware> createState() => _SignUpAlzAwareState();
}

class _SignUpAlzAwareState extends State<SignUpAlzAware> {

  String nameVal="", emailVal="", phoneVal="",passwordVal="", cpasswordVal="";
  FirebaseDatabase fbData = FirebaseDatabase.instance;
  bool signingUp = false;


  void createUser(BuildContext context) async{
    if(emailVal!="" && emailVal.contains('@')){
      if(passwordVal!=""){
        if(passwordVal==cpasswordVal){
          signingUp = true;
          setState(() {});
          final firebaseAuth = FirebaseAuth.instance;
          final fbRef = fbData.ref();
          final dbVal = {"fullname":nameVal,"phone":phoneVal, "email": emailVal};
          try{
            await firebaseAuth.createUserWithEmailAndPassword(email: emailVal, password: passwordVal);
            await fbRef.child(firebaseAuth.currentUser!.uid).set(dbVal);
            signingUp = false;
            setState(() {});
            Navigator.pop(context);
          }
          catch(e){
            String errorType = e.toString().substring(15);
            signingUp = false;
            setState(() {});
            if(errorType.startsWith("email")){
              Toast.show("Email already registered, please signin!", textStyle: const TextStyle(color: Colors.red,), backgroundColor: Colors.white, duration: Toast.lengthLong);
            }
          }
        }
        else{
          Toast.show("Please ensure passwords match!", textStyle: const TextStyle(color: Colors.red,), backgroundColor: Colors.white, duration: Toast.lengthLong);
        }
      }
      else{
        Toast.show("Please ensure password is not empty!", textStyle: const TextStyle(color: Colors.red,), backgroundColor: Colors.white, duration: Toast.lengthLong);
      }
    }
    else{
      Toast.show("Please enter a valid email!", textStyle: const TextStyle(color: Colors.red), backgroundColor: Colors.white, duration: Toast.lengthLong);
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: !signingUp?Padding(
        padding: const EdgeInsets.only(left:20,right:20,top:20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height:50,
              width:double.infinity,
              decoration:BoxDecoration(
                borderRadius:BorderRadius.circular(5),
                color: Theme.of(context).primaryColor,
              ),
              child: const Center(child: Text("Create New Account", style: TextStyle(color: Colors.white, fontSize:18),)),
            ),
            const SizedBox(height:60,),
            TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                hintText: "Full Name",
                hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
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
              onChanged: (val){
                nameVal =val;
                setState(() {

                });
              },
            ),
            const SizedBox(height: 20,),
            TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                hintText: "E-mail",
                hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
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
              onChanged: (val){
                emailVal=val;
                setState(() {

                });
              },
            ),
            const SizedBox(height: 20,),
            TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                hintText: "Phone Number",
                hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
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
              onChanged: (val){
                phoneVal = val;
                setState(() {

                });
              },
            ),
            const SizedBox(height: 20,),
            TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
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
              onChanged: (val){
                passwordVal=val;
                setState(() {

                });
              },
            ),
            const SizedBox(height: 20,),
            TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
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
              onChanged: (val){
                cpasswordVal=val;
                setState(() {

                });
              },
            ),

          ],
        ),
      ):LoadingWidget("Signing Up"),
      bottomNavigationBar:Padding(
        padding: const EdgeInsets.only(bottom:20,left:20,right:20),
        child: Container(
          width:double.infinity,
          decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          height: 50,
          child: ElevatedButton(
            onPressed: (){
              createUser(context);
            },
            child: const Text("Sign up", style: TextStyle(fontSize: 18,color:Colors.white),),
          ),
        ),
      ),
    );
  }
}