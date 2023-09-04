import 'package:alzaware/Basic%20Resources/LoadingWidget.dart';
import 'package:alzaware/chart.dart';
import 'package:alzaware/edit.dart';
import 'package:alzaware/widgets/my_text_field.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PortfolioAlzAware extends StatefulWidget {
  String uId;

  PortfolioAlzAware(this.uId, {super.key});

  @override
  State<PortfolioAlzAware> createState() => _PortfolioAlzAwareState();
}

class _PortfolioAlzAwareState extends State<PortfolioAlzAware> {
  String advice =
      "Follow these:\n1)An apple a day keeps doctor away\n2)Drink more water\n3)Eat oil-less food";

  String emeEmail = "";
  String emePhone = "";

  bool detailsLoaded = false;
  var userData;

  List<ChartData> alzValueSeries = [];
  List<String> alzValues = [];
  FirebaseDatabase fbData = FirebaseDatabase.instance;

  void initFirebase() {
    fbData.ref().child(widget.uId).once().then((res) {
      userData = res.snapshot.value;
      if (userData["advice"] != null) {
        advice = userData["advice"];
      }

      if (userData['eme_email'] != null) {
        emeEmail = userData['eme_email'];
      }

      if (userData['eme_phone'] != null) {
        emePhone = userData['eme_phone'];
      }

      detailsLoaded = true;
      /*     for (int i = 0; i < userData["recordings"].keys.length; i++) {
        var val = userData["recordings"].values.elementAt(i)["alzValue"];
        print(val);
        alzValueSeries.add(ChartData(
            i + 1,
            double.parse(
                userData["recordings"].values.elementAt(i)["alzValue"])));
      }*/
      print(userData);
      setState(() {});
    });
  }

  void initRecordings() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    Query query = databaseReference
        .child(widget.uId)
        .child("results")
        .orderByChild("results")
        .limitToLast(5);
    var data = await query.once();
    print("==========>");
    Map<dynamic, dynamic> result = data.snapshot.value as Map<dynamic, dynamic>;
    var onlyValues = result.values.toList();
    for (int i = 0; i < onlyValues.length; i++) {
      alzValueSeries.add(ChartData(i + 1, double.parse("${onlyValues[i]}")));
    }
    setState(() {});
  }

  @override
  void initState() {
    initRecordings();
    initFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Portfolio"),
      ),
      body: detailsLoaded
          ? Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(60),
                            bottomRight: Radius.circular(60)),
                        color: Color(0xFF6F8FAF),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                          ),
                          Text(
                            "Hello!",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(
                            detailsLoaded ? userData["fullname"] : "",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 160,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width,
                          child: CarouselSlider(
                            items: [
                              Stack(
                                children: [
                                  Card(
                                    elevation: 20,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(60),
                                      side: const BorderSide(
                                        width: 3,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        advice,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 15,
                                      right: 25,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            showAlertDialog(context);
                                          },
                                        ),
                                      ))
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChartAlzware(alzValueSeries),
                                      ));
                                },
                                child: Card(
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(60),
                                    side: const BorderSide(
                                      width: 3,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SfCartesianChart(
                                        primaryYAxis: NumericAxis(
                                            minimum: 0,
                                            maximum: 2,
                                            interval: 1),
                                        primaryXAxis: NumericAxis(
                                            minimum: 0,
                                            maximum: 5,
                                            interval: 1),
                                        series: [
                                          BarSeries(
                                            dataSource: alzValueSeries,
                                            xValueMapper: (ChartData data, _) =>
                                                data.x,
                                            yValueMapper: (ChartData data, _) =>
                                                data.y,
                                          ),
                                        ],
                                        isTransposed: true,
                                        palette: const [
                                          Colors.white,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            options: CarouselOptions(
                              autoPlay: true,
                              enlargeCenterPage: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Emergency contact: ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 18),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Icon(
                                    Icons.email,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      "email: $emeEmail",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      "Phone: $emePhone",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: 15,
                          right: 25,
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                updateEmergancyDialog(context);
                              },
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            )
          : LoadingWidget("Fetching User Portfolio"),
    );
  }

  void showAlertDialog(BuildContext context) {
    TextEditingController textEditingController =
        TextEditingController(text: advice);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Advice'),
          content: TextField(
            controller: textEditingController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onSubmitted: (text) {
              setState(() {
                // Append the entered text to the existing text
                textEditingController.text += "\n$text";
                textEditingController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textEditingController.text.length),
                );
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Retrieve and save the text
                Navigator.of(context).pop();
                detailsLoaded = true;
                updateAdvice(advice: textEditingController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void updateEmergancyDialog(BuildContext context) {
    TextEditingController email = TextEditingController(text: emeEmail);
    TextEditingController phone = TextEditingController(text: emePhone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: "Email"),
                onSubmitted: (text) {},
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Phone"),
                onSubmitted: (text) {},
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Retrieve and save the text
                /*updateAdvice(advice: textEditingController.text);*/
                Navigator.of(context).pop();
                detailsLoaded = true;
                updateEmergancyContact(email: email.text, phone: phone.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void updateAdvice({required String advice}) async {
    await fbData.ref().child(widget.uId).update({
      "advice":
          advice.contains("Follow these:") ? advice : "Follow these:\n$advice"
    });
    initFirebase();
    detailsLoaded = false;
  }

  void updateEmergancyContact(
      {required String email, required String phone}) async {
    await fbData
        .ref()
        .child(widget.uId)
        .update({"eme_email": email, "eme_phone": phone});
    initFirebase();
    detailsLoaded = false;
  }
}

class ChartData {
  final double x, y;
  ChartData(this.x, this.y);
}
