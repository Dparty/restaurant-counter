import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:restaurant_counter/views/restaurant_page.dart';
import 'package:restaurant_counter/api/account.dart';
import 'package:restaurant_counter/views/components/dialog.dart';

class SigninForm extends StatefulWidget {
  const SigninForm({super.key});

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  void signin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      signinApi(email.text, password.text).then((session) {
        prefs.setString('token', session.token).then((_) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const RestaurantsPage()));
        });
      }).onError((error, stackTrace) {
        // print(error);
        showAlertDialog(context, "登錄失敗\n${error.toString()}");
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: email,
              decoration: const InputDecoration(
                hintText: '帳號',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '請輸入帳號';
                }
                return null;
              },
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '密碼',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '請輸入密碼';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC88D67),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // _formKey.currentState!.save();
                    signin(context);
                  }
                },
                child: const Text('登入'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
