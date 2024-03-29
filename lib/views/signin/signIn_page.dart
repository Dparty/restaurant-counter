import 'package:flutter/material.dart';
import 'signIn_form.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 450,
          child: Material(
            color: Colors.white,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(
                "images/favicon.png",
                width: 300,
              ),
            ]),
          ),
        ),
        Expanded(
          child: Material(
            color: Colors.white,
            child: DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(150.0),
                    child: const Scaffold(
                        resizeToAvoidBottomInset: false, body: SigninForm()),
                  ),
                )),
          ),
        )
      ],
    );
  }
}
