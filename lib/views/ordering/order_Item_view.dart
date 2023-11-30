import 'package:flutter/material.dart';

// providers
import 'package:provider/provider.dart';
import 'package:restaurant_counter/provider/restaurant_provider.dart';
import 'package:restaurant_counter/provider/selected_table_provider.dart';

// components
import 'package:restaurant_counter/views/components/default_layout.dart';
import 'package:restaurant_counter/views/components/navbar.dart';
import 'package:restaurant_counter/views/components/item_card_list.dart';
import './shopping_cart.dart';
import './options_select.dart';

class OrderItem extends StatefulWidget {
  const OrderItem({super.key});
  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with TickerProviderStateMixin {
  TabController? _tabController;
  late final restaurant;

  @override
  void initState() {
    super.initState();
    restaurant = context.read<RestaurantProvider>();
    _tabController =
        TabController(length: restaurant.itemsMap.keys.length, vsync: this);
  }

  void onTapCallback(item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OptionSelect(item: item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final restaurant = context.read<RestaurantProvider>();
    // _tabController =
    //     TabController(length: restaurant.itemsMap.keys.length + 1, vsync: this);
    // _tabController =
    //     TabController(length: restaurant.itemsMap.keys.length, vsync: this);

    return DefaultLayout(
        left: SizedBox(
          width: 200,
          child: NavBar(
            showSettings: false,
          ),
        ),
        center: ListView(
          padding: const EdgeInsets.only(left: 20.0),
          children: <Widget>[
            const SizedBox(height: 15.0),
            Row(
              children: [
                Text('餐廳名稱：${restaurant.name}'),
                const SizedBox(width: 10),
                Text(
                    '餐桌號：${context.read<SelectedTableProvider>().selectedTable?.label}')
              ],
            ),
            Row(
              children: [
                Expanded(
                    flex: 8,
                    child: TabBar(
                        key: UniqueKey(),
                        controller: _tabController,
                        indicatorColor: Colors.transparent,
                        labelColor: Color(0xFFC88D67),
                        isScrollable: true,
                        labelPadding: const EdgeInsets.only(right: 45.0),
                        unselectedLabelColor: const Color(0xFFCDCDCD),
                        tabs: [
                          ...restaurant.itemsMap.keys.map(
                            (label) => Tab(
                              child: Text(label,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                  )),
                            ),
                          )
                        ])),
              ],
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height - 180.0,
                child: TabBarView(controller: _tabController, children: [
                  ...restaurant.itemsMap.keys.map(
                    (label) => ItemCardListView(
                      itemList: restaurant.itemsMap[label]?.toList(),
                      crossAxisCount: 3,
                      onTap: onTapCallback,
                    ),
                  )
                ]))
          ],
        ),
        centerTitle: '點餐',
        right: const ShoppingCart());
  }
}
