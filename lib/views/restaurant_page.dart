import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_counter/main.dart';
import 'package:restaurant_counter/models/restaurant.dart';
import 'package:restaurant_counter/views/ordering/ordering_page.dart';

import '../api/restaurant.dart';
import '../api/utils.dart';
import 'components/dialog.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<StatefulWidget> createState() => _RestaurantState();
}

class _RestaurantState extends State<RestaurantsPage> {
  late List<Restaurant> restaurants;

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var restaurantList;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    listRestaurant().then((value) {
      setState(() {
        restaurantList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return restaurantList == null
        ? const SizedBox(
            height: 300.0,
            width: 300.0,
            child: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('餐廳列表'),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      showAlertDialog(context, "確認退出APP?", onConfirmed: () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      });
                    },
                    icon: const Icon(Icons.close_outlined)),
                IconButton(
                    onPressed: () {
                      showAlertDialog(context, "確認退出登錄?", onConfirmed: () {
                        signout().then((_) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        });
                      });
                    },
                    icon: const Icon(Icons.logout))
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 40),
              child: Wrap(
                spacing: 20.0,
                runSpacing: 4.0,
                children: [
                  ...restaurantList.data.map((e) => SizedBox(
                        width: 300,
                        height: 300,
                        child: RestaurantCard(
                          restaurant: e,
                          key: Key(e.id),
                          reload: loadData,
                        ),
                      ))
                ],
              ),
            ));
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final Function? reload;

  const RestaurantCard({super.key, required this.restaurant, this.reload});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderingPage(
                      restaurant.id,
                    )));
      },
      child: Card(
        color: Colors.white,
        elevation: 8.0,
        margin: const EdgeInsets.all(4.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Image.asset(
                "./assets/images/favicon.png",
                height: 144,
                width: 144,
                fit: BoxFit.contain,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[800],
                          ),
                        ),
                        restaurant.description != ''
                            ? Text(
                                restaurant.description.length > 6
                                    ? '${restaurant.description.substring(0, 6)}...'
                                    : restaurant.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ))
                            : const SizedBox.shrink(),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderingPage(
                                        restaurant.id,
                                      )));
                        },
                        icon: const Icon(Icons.restaurant)),
                  ],
                ),
              ),
              // Add a small space between the card and the next widget
            ],
          ),
        ),
      ),
    );
  }
}
