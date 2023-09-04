import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  String message;

  LoadingWidget(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         CircularProgressIndicator(color: Theme.of(context).primaryColor,),
        const SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style:  TextStyle(color: Theme.of(context).primaryColor,),),
          ],
        )
      ],
    );
  }
}
