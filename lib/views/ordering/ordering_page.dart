import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:restaurant_counter/api/bill.dart';
import 'package:restaurant_counter/views/components/main_layout.dart';

import 'package:restaurant_counter/views/ordering/checkbills/check_bills.dart';

import 'package:provider/provider.dart';
import 'package:restaurant_counter/provider/restaurant_provider.dart';
import 'package:restaurant_counter/provider/selected_table_provider.dart';

import '../../api/utils.dart';
import '../../models/bill.dart';
import 'package:collection/collection.dart';

import '../../provider/socket_util.dart';

class OrderingPage extends StatefulWidget {
  final String restaurantId;
  const OrderingPage(this.restaurantId, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _OrderingPageState(restaurantId);
}

class _OrderingPageState extends State<OrderingPage> {
  final String restaurantId;
  Timer? _timeDilationTimer;
  List<String?> hasOrdersList = [];

  List<Bill>? oldOrders;
  List<String>? oldIdList;

  _OrderingPageState(this.restaurantId);

  @override
  void initState() {
    super.initState();

    if (mounted) {
      if (!kIsWeb) {
        WebSocketUtility().initWebSocket(
            id: restaurantId,
            onOpen: () {
              WebSocketUtility().initHeartBeat();
            },
            onMessage: (data) {
              print("message");
              List<Bill>? billList = (jsonDecode(data) as Iterable)
                  .map((e) => Bill.fromJson(e))
                  .toList();
              List<Bill>? submittedBills =
                  billList?.where((i) => i.status == 'SUBMITTED').toList();
              context
                  .read<SelectedTableProvider>()
                  .setAllTableOrders(submittedBills);
            },
            onError: (e) {
              print(e);
            });
      }
      // else {
      _timeDilationTimer?.cancel();
      _timeDilationTimer =
          Timer.periodic(const Duration(milliseconds: 3000), pollingBills);

      pollingBills(_timeDilationTimer!);
      // }
    }
  }

  pollingBills(Timer timer) {
    listBills(restaurantId, status: 'SUBMITTED').then((orders) {
      oldOrders = context.read<SelectedTableProvider>().tableOrders;

      // if (orders.length == oldOrders?.length) {
      //   oldIdList = oldOrders == null
      //       ? []
      //       : {...oldOrders!.map((e) => e.id).toList()}.toList();
      //
      //   if (const IterableEquality().equals(
      //       {...orders.map((e) => e.id).toList()}.toList(), oldIdList)) return;
      // }

      context.read<SelectedTableProvider>().setAllTableOrders(orders);
      final labelList = {...orders.map((e) => e.tableLabel).toList()}.toList();
      setState(() {
        hasOrdersList = labelList;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timeDilationTimer?.cancel();
    _timeDilationTimer = null;
    WebSocketUtility().closeSocket();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>();
    final tableProvider = context.read<SelectedTableProvider>();

    List<Bill>? orders = tableProvider.tableOrders;
    final List<String?> labelList = orders == null
        ? []
        : {...orders!.map((e) => e.tableLabel).toList()}.toList();
    print(labelList?.length);
    setState(() {
      hasOrdersList = labelList;
    });

    return MainLayout(
      // left: SizedBox(
      //   width: 200,
      //   child: NavBar(
      //     showSettings: false,
      //   ),
      // ),
      centerTitle: "選擇餐桌",
      center: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('餐廳名稱：${restaurant.name}'),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120, //200
                      childAspectRatio: 1,
                      crossAxisSpacing: 5, // 20
                      mainAxisSpacing: 5), //20
                  itemCount: restaurant.tables.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: OutlinedButton(
                            key: Key(index.toString()),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                width: 1.0,
                                color: tableProvider.selectedTable?.label ==
                                        restaurant.tables[index].label
                                    ? const Color(0xFFC88D67)
                                    : const Color(0xFFFFECDF),
                              ),
                              backgroundColor: hasOrdersList
                                      .contains(restaurant.tables[index].label)
                                  ? const Color(0xFFFFECDF)
                                  : Colors.white,
                            ),
                            onPressed: () {
                              tableProvider
                                  .selectTable(restaurant.tables[index]);

                              tableProvider.setSelectedBillIds(tableProvider
                                  .tableOrders
                                  ?.where((i) =>
                                      i.tableLabel ==
                                      restaurant.tables[index].label)
                                  .toList()
                                  .map((e) => e.id)
                                  .toList());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  restaurant.tables[index].label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                              ),
                            )),
                      ),
                    );
                  }),
            ),
          ]),
      right: CheckBillsView(
          table: context.watch<SelectedTableProvider>().selectedTable,
          toOrderCallback: () {
            print("toOrderCallback");
            _timeDilationTimer?.cancel();
            _timeDilationTimer = null;
            WebSocketUtility().closeSocket();
          }),
    );
  }
}
