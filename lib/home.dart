import 'package:alzaware/journal.dart';
import 'package:alzaware/portfolio.dart';
import 'package:alzaware/predict.dart';
import 'package:alzaware/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeAlzAware extends StatefulWidget {
  final String uId;

  const HomeAlzAware(this.uId, {super.key});

  @override
  State<HomeAlzAware> createState() => _HomeAlzAwareState();
}

class _HomeAlzAwareState extends State<HomeAlzAware> {
  String recordCount = "1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // title:Text("AlzAware"),
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut().then((res) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const SignInAlzAware()),
                    (route) => false);
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  Icon(Icons.logout),
                  Text("Logout"),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PortfolioAlzAware(widget.uId)));
              },
              child: MenuCard("assets/images/portfolio.png", "Portfolio"),
            ),
            const Row(
              children: [
                SizedBox(
                  height: 30,
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PredictAlzAware(widget.uId, recordCount)));
              },
              child: MenuCard("assets/images/prediction.png", "Predict"),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JournalAlzAware(widget.uId)));
              },
              child: MenuCard("assets/images/journal.png", "Journal"),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  String assetPath, menuText;
  double cardHeight = 0.0, cardWidth = 0.0;
  MenuCard(this.assetPath, this.menuText, {super.key});

  @override
  Widget build(BuildContext context) {
    cardWidth = MediaQuery.of(context).size.width * 0.8;
    cardHeight = MediaQuery.of(context).size.height * 0.22;
    return SizedBox(
      height: cardHeight,
      width: double.infinity,
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image(
                image: AssetImage(assetPath),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              menuText,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}
