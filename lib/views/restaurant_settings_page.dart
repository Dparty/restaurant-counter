import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:restaurant_counter/views/components/dialog.dart';
import 'package:restaurant_counter/views/components/default_layout.dart';
import 'package:restaurant_counter/views/ordering/ordering_page.dart';

import 'package:restaurant_counter/models/restaurant.dart' as model;
import '../api/restaurant.dart';
import '../api/utils.dart';
import '../models/bill.dart';
import '../provider/selected_table_provider.dart';
import '../provider/socket_util.dart';
import 'components/navbar.dart';

import 'package:restaurant_counter/provider/restaurant_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RestaurantSettingsPage extends StatefulWidget {
  final String restaurantId;
  final int? selectedNavIndex;

  const RestaurantSettingsPage(
      {super.key, required this.restaurantId, this.selectedNavIndex});

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _RestaurantSettingsPageState(restaurantId: restaurantId);
}

class _RestaurantSettingsPageState extends State<RestaurantSettingsPage>
    with SingleTickerProviderStateMixin {
  final String restaurantId;
  model.Restaurant restaurant = const model.Restaurant(
      id: '', name: '', description: '', items: [], tables: [], categories: []);
  List<model.Item> items = [];
  List<model.Printer> printers = [];
  int _selectedIndex = 0; // for mobile bottom navigation
  int _selectedNavIndex = 0; // for desktop left bar navigation

  var scaffoldKey = GlobalKey<ScaffoldState>();

  _RestaurantSettingsPageState({required this.restaurantId});

  void loadRestaurant() async {
    final token = await getToken();

    getRestaurant(restaurantId).then((restaurant) {
      setState(() {
        this.restaurant = restaurant;
        items = restaurant.items;
      });

      context.read<RestaurantProvider>().setRestaurant(
            restaurant.id,
            restaurant.name,
            restaurant.description,
            restaurant.items,
            restaurant.tables,
            restaurant.categories,
          );
    });

    //
    // WebSocketChannel _channel = IOWebSocketChannel.connect(
    //     "wss://restaurant-uat.sum-foods.com/bills/subscription?restaurantId=${restaurantId}",
    //     headers: {
    //       'Content-type': 'application/json',
    //       'Accept': 'application/json',
    //       'Authorization': 'Bearer ${token}'
    //       // 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE3MTcwNzk0MzAwMzMwNTE2NDgiLCJlbWFpbCI6Imp5ZThAdWFsYmVydGEuY2EiLCJyb2xlIjoiVVNFUiJ9.2_yI8_FBHqZhLDc6RnCfJcydzSm3TUolDBYY7NLmClI'
    //     });
    // print("========================");
    // print(_channel);
    //
    // await _channel.ready; // ready is a future
    //
    // print('WS connected');

    listPrinters(restaurantId).then((list) => setState(() {
          printers = list.data;
          context.read<RestaurantProvider>().setRestaurantPrinter(list.data);
        }));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.selectedNavIndex != null) {
        _selectedNavIndex = widget.selectedNavIndex!;
      }
    });
    loadRestaurant();
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      left: SizedBox(
        width: 200,
        child: NavBar(
          onTap: _onNavTapped,
        ),
      ),
      centerTitle: "點餐",
      center: OrderingPage(restaurantId),
    );
  }
}
