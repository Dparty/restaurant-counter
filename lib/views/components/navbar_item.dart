import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  const NavItem(
      {Key? key,
      required this.name,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  final String name;
  final IconData icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 16), //, color: Colors.white
            )
          ],
        ),
      ),
    );
  }
}
