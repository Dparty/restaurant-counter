import 'package:flutter/material.dart';

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final String text;
  const PlusMinusButtons(
      {Key? key,
      required this.addQuantity,
      required this.deleteQuantity,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: deleteQuantity,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Color(0xFFC88D67),
          ),
          child: const Icon(
            Icons.remove,
          ),
        ),
        Text(text),
        ElevatedButton(
          onPressed: addQuantity,
          style: ElevatedButton.styleFrom(
              shape: const CircleBorder(), backgroundColor: Color(0xFFC88D67)),
          child: const Icon(
            Icons.add,
          ),
        ),
      ],
    );
  }
}
