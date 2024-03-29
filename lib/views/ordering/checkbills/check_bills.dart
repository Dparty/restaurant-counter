import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:restaurant_counter/api/bill.dart';
import 'package:restaurant_counter/views/components/dialog.dart';
import '../../../api/restaurant.dart';
import '../../../models/order.dart';
import '../order_Item_view.dart';

// models
import 'package:restaurant_counter/models/restaurant.dart' as model;
import 'package:restaurant_counter/models/bill.dart';

// providers
import 'package:provider/provider.dart';
import 'package:restaurant_counter/provider/selected_table_provider.dart';
import 'package:restaurant_counter/provider/restaurant_provider.dart';
import 'package:restaurant_counter/views/ordering/checkbills/cart_card.dart';
import 'offset_options_dialog.dart';

class BillCheckbox extends StatelessWidget {
  const BillCheckbox({
    super.key,
    required this.bill,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Bill bill;

  @override
  Widget build(BuildContext context) {
    void onBillTap(Bill bill) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShowCurrentBill(orders: bill);
        },
      );
    }

    return GestureDetector(
      onTap: () {
        onBillTap(bill);
      },
      child: Card(
        child: ClipPath(
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3))),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFFFECDF), width: 5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('取餐號：${bill.pickUpCode}'),
                      Text('總價：\$${(bill.total / 100).toString()}')
                    ],
                  )),
                  Checkbox(
                    value: value,
                    onChanged: (bool? newValue) {
                      onChanged(newValue!);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CheckBillsView extends StatefulWidget {
  final model.Table? table;
  final Function? toOrderCallback;

  const CheckBillsView({Key? key, this.table, this.toOrderCallback})
      : super(key: key);

  @override
  State<CheckBillsView> createState() => _CheckBillsViewState();
}

class _CheckBillsViewState extends State<CheckBillsView> {
  int _offset = 0;
  bool checkedValue = false;

  @override
  Widget build(BuildContext context) {
    List<Bill>? bills =
        context.watch<SelectedTableProvider>().tableOrders?.toList();

    // List<Bill>? selectedTableBills = bills
    //     ?.where((i) =>
    //         i.tableLabel == widget.table?.label && i.status == 'SUBMITTED')
    //     .toList();
    List<Bill>? selectedTableBills = bills
        ?.where((i) =>
            i.tableLabel == widget.table?.label &&
            (i.status == 'SUBMITTED' ||
                (checkedValue == true && i.status == 'PAIED')))
        .toList();

    bool hasBills =
        bills?.where((i) => i.tableLabel == widget.table?.label)?.isNotEmpty ??
            false;

    List<String>? selectedTableBillsIds =
        selectedTableBills?.map((e) => e.id).toList();

    final restaurant = context.watch<RestaurantProvider>();
    final table = context.watch<SelectedTableProvider>().selectedTable;

    final selectedIds =
        context.watch<SelectedTableProvider>().selectedBillIds ?? [];

    void setCheckAll(bool select) {
      if (select == false) {
        context.read<SelectedTableProvider>().setSelectedBillIds([]);
      } else {
        context
            .read<SelectedTableProvider>()
            .setSelectedBillIds(selectedTableBillsIds);
      }
    }

    final discount = context.watch<RestaurantProvider>().discount;

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('${table?.label ?? ''}訂單列表')),
        body: !hasBills
            ? Center(
                child: Column(
                children: [
                  const Text("暫無訂單"),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.table == null) {
                        showAlertDialog(context, "請選擇桌號");
                        return;
                      }
                      widget.toOrderCallback!();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OrderItem()));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 1000.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: const Color(0xFFC88D67)),
                      child: const Center(
                          child: Text(
                        '前往點單',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                    ),
                  ),
                ],
              ))
            : Column(
                children: [
                  CheckboxListTile(
                    title: const Text("顯示已完成訂單"),
                    value: checkedValue,
                    onChanged: (newValue) {
                      setState(() {
                        checkedValue = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, //  <-- leading Checkbox
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("全部選擇/取消"),
                            Checkbox(
                                // value: !_isSelected.contains(false),
                                value: selectedIds.isNotEmpty,
                                onChanged: (val) {
                                  setState(() {
                                    setCheckAll(val!);
                                  });
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      ...?selectedTableBills?.mapIndexed(
                        (index, bill) => BillCheckbox(
                          bill: bill,
                          label: "取餐號：${bill.pickUpCode.toString()}",
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          value: selectedIds.contains(bill.id),
                          onChanged: (bool newValue) {
                            setState(() {
                              if (newValue == true) {
                                context
                                    .read<SelectedTableProvider>()
                                    .addId(bill.id);
                              } else {
                                context
                                    .read<SelectedTableProvider>()
                                    .removeId(bill.id);
                              }
                            });
                          },
                        ),
                      )
                    ],
                  ))),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 40),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (widget.table == null) {
                                showAlertDialog(context, "請選擇桌號");
                                return;
                              }
                              widget.toOrderCallback!();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const OrderItem()));
                            },
                            child: Container(
                              width: 150,
                              height: 35.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: const Color(0xFFC88D67)),
                              child: const Center(
                                  child: Text(
                                '前往點單',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (selectedIds.isEmpty) {
                                    showAlertDialog(context, "請勾選需要打印的訂單");
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (innerContext) => offsetOptions(
                                      discountList: discount,
                                      onSelected: (offset) {
                                        setState(() {
                                          _offset = offset;
                                        });
                                      },
                                      onConfirmed: () {
                                        printBills(selectedIds, _offset)
                                            .then((e) {
                                          // showAlertDialog(context, "訂單已打印");
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text("訂單已打印"),
                                                  content: Container(
                                                    width: 150,
                                                    height: 35.0,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color: const Color(
                                                            0xFFC88D67)),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        await setBills(
                                                                selectedIds,
                                                                _offset,
                                                                'PAIED')
                                                            .then((e) {
                                                          Navigator.pop(
                                                              context);
                                                          showAlertDialog(
                                                              context, "訂單已完成");
                                                          listBills(
                                                                  restaurant.id,
                                                                  tableId:
                                                                      table?.id)
                                                              .then((orders) {
                                                            context
                                                                .read<
                                                                    SelectedTableProvider>()
                                                                .setAllTableOrders(
                                                                    orders);
                                                            context
                                                                .read<
                                                                    SelectedTableProvider>()
                                                                .setSelectedBillIds(
                                                                    []);
                                                          });
                                                        });
                                                      },
                                                      child: const Center(
                                                          child: Text(
                                                        '完成訂單',
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      )),
                                                    ),
                                                  ),
                                                  // actions: [
                                                  //
                                                  // ],
                                                );
                                              });
                                        });
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: const Color(0xFFC88D67)),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (selectedIds.isEmpty) {
                                        showAlertDialog(context, "請勾選需要打印的訂單");
                                        return;
                                      }
                                      showDialog(
                                        context: context,
                                        builder: (innerContext) =>
                                            offsetOptions(
                                          discountList: discount,
                                          onSelected: (offset) {
                                            setState(() {
                                              _offset = offset;
                                            });
                                          },
                                          onConfirmed: () {
                                            printBills(selectedIds, _offset)
                                                .then((e) {
                                              // showAlertDialog(context, "訂單已打印");
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text("訂單已打印"),
                                                      content: Container(
                                                        width: 150,
                                                        height: 35.0,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            color: const Color(
                                                                0xFFC88D67)),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            await setBills(
                                                                    selectedIds,
                                                                    _offset,
                                                                    'PAIED')
                                                                .then((e) {
                                                              Navigator.pop(
                                                                  context);
                                                              showAlertDialog(
                                                                  context,
                                                                  "訂單已完成");
                                                              listBills(
                                                                      restaurant
                                                                          .id,
                                                                      tableId:
                                                                          table
                                                                              ?.id)
                                                                  .then(
                                                                      (orders) {
                                                                context
                                                                    .read<
                                                                        SelectedTableProvider>()
                                                                    .setAllTableOrders(
                                                                        orders);
                                                                context
                                                                    .read<
                                                                        SelectedTableProvider>()
                                                                    .setSelectedBillIds(
                                                                        []);
                                                              });
                                                            });
                                                          },
                                                          child: const Center(
                                                              child: Text(
                                                            '完成訂單',
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                        ),
                                                      ),
                                                      // actions: [
                                                      //
                                                      // ],
                                                    );
                                                  });
                                            });
                                          },
                                        ),
                                      );
                                    },
                                    child: const Center(
                                        child: Text(
                                      '打印訂單',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (selectedIds!.isEmpty) {
                                    showAlertDialog(context, "請勾選需要打印的訂單");
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (innerContext) => offsetOptions(
                                      discountList: discount,
                                      onSelected: (offset) {
                                        setState(() {
                                          _offset = offset;
                                        });
                                      },
                                      onConfirmed: () async {
                                        await setBills(
                                                selectedIds, _offset, 'PAIED')
                                            .then((e) {
                                          showAlertDialog(context, "訂單已完成");
                                          listBills(restaurant.id,
                                                  tableId: table?.id)
                                              .then((orders) {
                                            context
                                                .read<SelectedTableProvider>()
                                                .setAllTableOrders(orders);
                                            context
                                                .read<SelectedTableProvider>()
                                                .setSelectedBillIds([]);
                                          });
                                        });
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: const Color(0xFFC88D67)),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (selectedIds!.isEmpty) {
                                        showAlertDialog(context, "請勾選需要打印的訂單");
                                        return;
                                      }

                                      showDialog(
                                        context: context,
                                        builder: (innerContext) =>
                                            offsetOptions(
                                          discountList: discount,
                                          onSelected: (offset) {
                                            setState(() {
                                              _offset = offset;
                                            });
                                          },
                                          onConfirmed: () async {
                                            await setBills(selectedIds, _offset,
                                                    'PAIED')
                                                .then((e) {
                                              showAlertDialog(context, "訂單已完成");
                                              listBills(restaurant.id,
                                                      tableId: table?.id)
                                                  .then((orders) {
                                                context
                                                    .read<
                                                        SelectedTableProvider>()
                                                    .setAllTableOrders(orders);
                                                context
                                                    .read<
                                                        SelectedTableProvider>()
                                                    .setSelectedBillIds([]);
                                              });
                                            });
                                          },
                                        ),
                                      );
                                    },
                                    child: const Center(
                                        child: Text(
                                      '完成訂單',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
                ],
              ));
  }
}

class ShowCurrentBill extends StatefulWidget {
  final Bill orders;
  const ShowCurrentBill({Key? key, required this.orders}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShowCurrentBillState();
}

class _ShowCurrentBillState extends State<ShowCurrentBill> {
  late List<Order> tmpOrders;
  List<model.Specification> deleted = [];
  final TextEditingController _confirm = TextEditingController();
  String? valueText;

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('請輸入密碼確認'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _confirm,
              decoration: const InputDecoration(hintText: "請輸入密碼"),
            ),
            actions: <Widget>[
              MaterialButton(
                // textColor: kPrimaryColor,
                child: const Text('取消'),
                onPressed: () {
                  setState(() {
                    _confirm.text = "";
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: const Color(0xFFC88D67),
                textColor: Colors.white,
                child: const Text('確認'),
                onPressed: () async {
                  if (valueText == '643769') {
                    await cancelBillItems(widget.orders.id, deleted).then((e) {
                      Navigator.of(context).pop();
                      showAlertDialog(context, "訂單已修改");
                    });
                  } else {
                    _confirm.text = "";
                    Navigator.pop(context);
                    showAlertDialog(context, "密碼錯誤");
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      tmpOrders = List.from(widget.orders.orders);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("取餐號：${widget.orders?.pickUpCode}"),
      content: Builder(builder: (context) {
        var height = MediaQuery.of(context).size.height - 200;
        var width = MediaQuery.of(context).size.width - 800;
        return Column(
          children: [
            Container(
              width: 150,
              height: 35.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xFFC88D67)),
              child: InkWell(
                onTap: () async {
                  await _displayTextInputDialog(context);
                  _confirm.text = '';
                  // showAlertDialog(
                  //   context,
                  //   "確認修改訂單?",
                  //   onConfirmed: () async {
                  //     await cancelBillItems(widget.orders.id, deleted)
                  //         .then((e) {
                  //       Navigator.of(context).pop();
                  //       showAlertDialog(context, "訂單已修改");
                  //     });
                  //   },
                  // );
                },
                child: const Center(
                    child: Text(
                  '提交更改',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
              ),
            ),
            SizedBox(
              height: height,
              width: width,
              child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: tmpOrders
                      .asMap()
                      .map((i, element) => MapEntry(
                          i,
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CartCardForBill(
                                item: element.item,
                                specification: element.specification,
                                onDelete: () {
                                  tmpOrders.removeAt(i);
                                  deleted.add(model.Specification(
                                    itemId: element.item.id,
                                    options: element.specification.toList(),
                                  ));
                                  setState(() {
                                    tmpOrders = tmpOrders;
                                    deleted = deleted;
                                  });
                                }),
                          )))
                      .values
                      .toList()),
            )
          ],
        );
      }),
    );
  }
}
