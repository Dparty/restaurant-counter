import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:restaurant_counter/api/bill.dart';
import 'package:restaurant_counter/views/components/dialog.dart';
import '../order_Item_view.dart';

// models
import 'package:restaurant_counter/models/restaurant.dart' as model;
import 'package:restaurant_counter/models/bill.dart';

// providers
import 'package:provider/provider.dart';
import 'package:restaurant_counter/provider/selected_table_provider.dart';
import 'package:restaurant_counter/provider/restaurant_provider.dart';

import 'offset_options_dialog.dart';

class BillCheckbox extends StatelessWidget {
  const BillCheckbox({
    super.key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    List<Bill>? bills =
        context.watch<SelectedTableProvider>().tableOrders?.toList();

    List<Bill>? selectedTableBills =
        bills?.where((i) => i.tableLabel == widget.table?.label).toList();
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

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('${table?.label ?? ''}訂單列表')),
        body: selectedTableBills != null && selectedTableBills.isEmpty
            ? Center(
                child: Column(
                children: [
                  const Text("暫無訂單"),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width - 1000.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Color(0xFFC88D67)),
                      child: InkWell(
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
                        child: const Center(
                            child: Text(
                          '前往點單',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      ))
                ],
              ))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Row(
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
                    ),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      ...?selectedTableBills?.mapIndexed(
                        (index, order) => BillCheckbox(
                          label: "取餐號：${order.pickUpCode.toString()}",
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          value: selectedIds.contains(order.id),
                          onChanged: (bool newValue) {
                            setState(() {
                              if (newValue == true) {
                                context
                                    .read<SelectedTableProvider>()
                                    .addId(order.id);
                              } else {
                                context
                                    .read<SelectedTableProvider>()
                                    .removeId(order.id);
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
                          Container(
                              width: 150,
                              height: 35.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Color(0xFFC88D67)),
                              child: InkWell(
                                onTap: () {
                                  if (widget.table == null) {
                                    showAlertDialog(context, "請選擇桌號");
                                    return;
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const OrderItem()));
                                },
                                child: const Center(
                                    child: Text(
                                  '前往點單',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 150,
                                height: 35.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Color(0xFFC88D67)),
                                child: InkWell(
                                  onTap: () async {
                                    if (selectedIds.isEmpty) {
                                      showAlertDialog(context, "請勾選需要打印的訂單");
                                      return;
                                    }
                                    showDialog(
                                      context: context,
                                      builder: (innerContext) => offsetOptions(
                                        defaultOffset: _offset,
                                        onSelected: (offset) {
                                          setState(() {
                                            _offset = offset;
                                          });
                                        },
                                        onConfirmed: () {
                                          printBills(selectedIds, _offset)
                                              .then((e) {
                                            showAlertDialog(context, "訂單已打印");
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
                              Container(
                                width: 150,
                                height: 35.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Color(0xFFC88D67)),
                                child: InkWell(
                                  onTap: () async {
                                    if (selectedIds!.isEmpty) {
                                      showAlertDialog(context, "請勾選需要打印的訂單");
                                      return;
                                    }

                                    showDialog(
                                      context: context,
                                      builder: (innerContext) => offsetOptions(
                                        defaultOffset: _offset,
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
                                                    status: 'SUBMITTED',
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
                                  child: const Center(
                                      child: Text(
                                    '完成訂單',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                                ),
                              )
                            ],
                          ),
                        ],
                      ))
                ],
              ));
  }
}
