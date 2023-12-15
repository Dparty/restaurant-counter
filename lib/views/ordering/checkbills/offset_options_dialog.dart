import 'package:flutter/material.dart';
import 'package:restaurant_counter/models/restaurant.dart';

class DiscountWrapper {
  DiscountWrapper({this.discountList = const [], this.value = false});
  List<List<dynamic>> discountList;
  bool value;
}

class offsetOptions extends StatefulWidget {
  int? selectedIndex = 0;
  List? discountList = [];
  final Function? onSelected;
  final Function? onConfirmed;
  offsetOptions(
      {Key? key,
      this.selectedIndex,
      this.onSelected,
      this.onConfirmed,
      this.discountList})
      : super(key: key);

  @override
  State<offsetOptions> createState() => _offsetOptionsState();
}

class _offsetOptionsState extends State<offsetOptions> {
  // late List<dynamic> checkListItems;
  late int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // var target = checkListItems
    //     .firstWhere((item) => item["offset"] == widget.defaultOffset);
    // if (target != null) {
    //   target["value"] = true;
    // }

    // checkListItems = List.from(widget.discountList ?? []);
    //
    // for (int i = 0; i < checkListItems!.length; i++) {
    //   print(checkListItems![i].label);
    //   checkListItems![i]['value'] = 'false';
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //默認選第一個
      widget.onSelected!(widget.discountList![0].offset);
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    widget.onConfirmed!();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        scrollable: true,
        title: const Text("折扣選擇"),
        content: SizedBox(
            height: MediaQuery.of(context).size.height - 350,
            width: MediaQuery.of(context).size.width - 1000,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: List.generate(
                      widget.discountList!.length,
                      (index) => CheckboxListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        activeColor: const Color(0xFFC88D67),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          widget.discountList![index].label,
                        ),
                        value: selectedIndex == index,
                        onChanged: (value) {
                          if (value == null) return;
                          widget
                              .onSelected!(widget.discountList![index].offset);
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _cancel,
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.grey),
                          child: const Text(
                            "取消",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: Color(0xFFC88D67)),
                          child: const Text(
                            "確定",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ))
        // Builder(builder: (context) {
        //   var height = MediaQuery.of(context).size.height;
        //   var width = MediaQuery.of(context).size.width;
        //   return SizedBox(
        //       height: height - 500,
        //       width: width - 1000,
        //       child: Column(
        //         children: [
        //           Expanded(
        //             child: Column(
        //               children: List.generate(
        //                 widget.discountList!.length,
        //                 // checkListItems.length,
        //                 (index) => CheckboxListTile(
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(8),
        //                   ),
        //                   activeColor: const Color(0xFFC88D67),
        //                   controlAffinity: ListTileControlAffinity.leading,
        //                   contentPadding: EdgeInsets.zero,
        //                   dense: true,
        //                   title: Text(
        //                     widget.discountList![index].label,
        //                   ),
        //                   value: selectedIndex == index,
        //                   onChanged: (value) {
        //                     if (value == null) return;
        //                     widget.onSelected!(
        //                         widget.discountList![index].offset);
        //                     setState(() {
        //                       selectedIndex = index;
        //                     });
        //                   },
        //                 ),
        //               ),
        //             ),
        //           ),
        //           Row(
        //             children: [
        //               Row(
        //                 children: [
        //                   ElevatedButton(
        //                     onPressed: _cancel,
        //                     style: ElevatedButton.styleFrom(
        //                         shape: const StadiumBorder(),
        //                         backgroundColor: Colors.grey),
        //                     child: const Text(
        //                       "取消",
        //                       style: TextStyle(color: Colors.white),
        //                     ),
        //                   ),
        //                   const SizedBox(width: 20),
        //                   ElevatedButton(
        //                     onPressed: _submit,
        //                     style: ElevatedButton.styleFrom(
        //                         shape: const StadiumBorder(),
        //                         backgroundColor: Color(0xFFC88D67)),
        //                     child: const Text(
        //                       "確定",
        //                       style: TextStyle(color: Colors.white),
        //                     ),
        //                   ),
        //                 ],
        //               )
        //             ],
        //           )
        //         ],
        //       ));
        // }

        );
  }
}
