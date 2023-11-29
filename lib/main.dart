import 'package:flutter/material.dart';
import 'package:restaurant_counter/api/utils.dart';
import 'package:restaurant_counter/provider/selected_printer_provider.dart';
import 'package:restaurant_counter/views/restaurant_page.dart';
import 'package:restaurant_counter/views/signin/signIn_page.dart';

import 'package:provider/provider.dart';
import 'package:restaurant_counter/provider/restaurant_provider.dart';
import 'package:restaurant_counter/provider/selected_table_provider.dart';
import 'package:restaurant_counter/provider/shopping_cart_provider.dart';
import 'package:restaurant_counter/provider/selected_item_provider.dart';

import 'configs/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => SelectedTableProvider()),
        ChangeNotifierProvider(create: (_) => SelectedPrinterProvider()),
        ChangeNotifierProvider(create: (_) => SelectedItemProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: "和食云",
        theme: AppTheme.lightTheme(context),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  void init() {
    getToken().then((token) {
      if (token == "") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SigninPage()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const RestaurantsPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    init();
    return const Scaffold(
      body: Text('Loading..'),
    );
  }
}
