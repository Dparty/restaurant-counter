import 'package:flutter/material.dart';
import 'package:restaurant_counter/views/restaurant_settings_page.dart';
import 'navbar_item.dart';
import 'package:restaurant_counter/main.dart';
import 'package:restaurant_counter/api/utils.dart';
import 'package:restaurant_counter/views/restaurant_page.dart';

// providers
import 'package:provider/provider.dart';
import 'package:restaurant_counter/provider/restaurant_provider.dart';
import 'package:restaurant_counter/provider/selected_table_provider.dart';
import 'package:restaurant_counter/provider/selected_printer_provider.dart';
import 'package:restaurant_counter/provider/selected_item_provider.dart';
import 'package:restaurant_counter/provider/shopping_cart_provider.dart';

class NavBar extends StatelessWidget {
  NavBar({Key? key, this.navIndex, this.onTap, this.showSettings})
      : super(key: key);

  final int? navIndex;
  bool? showSettings = true;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20, 12, 0),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              NavItem(
                name: '餐廳列表',
                icon: Icons.list,
                onPressed: () => onItemPressed(context, index: 4),
              ),
              const SizedBox(
                height: 20,
              ),
              NavItem(
                name: '點餐',
                icon: Icons.restaurant_rounded,
                onPressed: () => onItemPressed(context, index: 3),
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(
                thickness: 1,
                height: 10,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 30,
              ),
              NavItem(
                  name: '登出',
                  icon: Icons.logout,
                  onPressed: () => onItemPressed(context, index: 5)),
            ],
          ),
        ),
      ),
    );
  }

  void onItemPressed(BuildContext context,
      {required int index, Function? onTap}) {
    final restaurant = context.read<RestaurantProvider>();
    if (onTap != null) {
      onTap!(index);
    }
    context.read<CartProvider>().resetShoppingCart();
    context.read<SelectedTableProvider>().resetSelectTable();
    context.read<SelectedPrinterProvider>().resetSelectPrinter();
    context.read<SelectedItemProvider>().resetSelectItem();

    switch (index) {
      case 3:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RestaurantSettingsPage(
                      restaurantId: restaurant.id,
                      selectedNavIndex: 3,
                    )));
        break;
      case 4:
        Navigator.pop(context);
        context.read<RestaurantProvider>().resetRestaurant();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RestaurantsPage()));

        break;
      case 5:
        Navigator.pop(context);
        (() {
          signout().then((_) {
            context.read<RestaurantProvider>().resetRestaurant();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          });
        })();

        break;
    }
  }
}
