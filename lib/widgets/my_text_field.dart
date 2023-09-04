import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({super.key});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          onSubmitted: (text) {
            setState(() {
              // Append the entered text to the existing text
              _textEditingController.text += "\n$text";
              _textEditingController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textEditingController.text.length),
              );
            });
          },
        ),
        ElevatedButton(
          onPressed: () {
            // Retrieve and save the text
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
