import 'package:flutter/material.dart';
import 'package:restaurant_counter/api/config.dart';

import 'package:restaurant_counter/models/cart_item.dart';
import 'package:restaurant_counter/models/restaurant.dart' as model;
import 'package:restaurant_counter/models/model.dart';

import 'package:provider/provider.dart';
import 'package:restaurant_counter/provider/shopping_cart_provider.dart';

// components
import 'package:restaurant_counter/views/components/plus_minus_buttons.dart';

// CartCard in shopping cart
class CartCard extends StatelessWidget {
  final int index;
  const CartCard({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<CartProvider>();

    return Row(
      children: [
        SizedBox(
          width: 88,
          child: AspectRatio(
            aspectRatio: 0.88,
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFECDF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image(
                    image: ResizeImage(
                  NetworkImage(
                    item.image.isEmpty
                        ? ("$defaultImage?imageView2/1/w/144/q/85")
                        : ("${item.image}?imageView2/1/w/144/q/85"),
                  ),
                  width: 144,
                ))),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Text(
                  item.selectedItems.toString(),
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("價格：${item.price / 100}")),
                    Row(
                      children: [
                        PlusMinusButtons(
                            addQuantity: () => {provider.addQuantity(item)},
                            deleteQuantity: () => {provider.removeItem(item)},
                            text: item.quantity.toString()),
                        IconButton(
                            onPressed: () {
                              provider.deleteQuantity(item);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade800,
                            )),
                      ],
                    )
                  ],
                )
              ],
            )),
      ],
    );
  }
}

// CartCard for current bill review
class CartCardForBill extends StatelessWidget {
  const CartCardForBill({
    Key? key,
    required this.item,
    required this.specification,
  }) : super(key: key);

  final model.Item item;
  final Iterable<Pair> specification;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: AspectRatio(
            aspectRatio: 0.98,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFFFECDF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: FadeInImage(
                image: NetworkImage(
                    item.images.isEmpty ? defaultImage : item.images[0]),
                placeholder: const AssetImage("images/default.png"),
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset("images/default.png",
                      fit: BoxFit.fitWidth);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name!,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    ...specification.map((e) => Text(
                          "${e.left}: ${e.right};",
                        ))
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("價格：\$${item.pricing / 100}")),
                  ],
                )
              ],
            )),
        const SizedBox(width: 20),
      ],
    );
  }
}
