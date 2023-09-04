import 'package:flutter/material.dart';

class EditAlzAware extends StatefulWidget {
  const EditAlzAware({Key? key}) : super(key: key);

  @override
  State<EditAlzAware> createState() => _EditAlzAwareState();
}

class _EditAlzAwareState extends State<EditAlzAware> {

  String nameVal="", phoneVal="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.black,
                padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
                child: Text("Edit Details", style: TextStyle(color: Colors.white, fontSize: 22),),
              ),
            ],
          ),
          SizedBox(height: 80,),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.9,
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                  hintText: "Full Name",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none
              ),
              onChanged: (val){
                nameVal =val;
                setState(() {

                });
              },
            ),
          ),
          SizedBox(height: 20,),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.9,
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                  hintText: "Phone Number",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none
              ),
              onChanged: (val){
                phoneVal=val;
                setState(() {

                });
              },
            ),
          ),
          SizedBox(height: 30,),
          Container(
            height: 50,
            width: 150,
            child: ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("Update", style: TextStyle(fontSize: 18),),
            ),
          ),
        ],
      ),
    );
  }
}
