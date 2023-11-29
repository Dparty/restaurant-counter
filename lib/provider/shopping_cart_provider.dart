import 'package:flutter/material.dart';
import 'package:restaurant_counter/models/cart_item.dart';
import 'package:collection/collection.dart';
import 'package:restaurant_counter/models/restaurant.dart';

class CartProvider with ChangeNotifier {
  int get quantity => cart.map((e) => e.quantity).sum;
  Map<String, List<CartItem>> cartMap = {};
  List<CartItem> cart = [];
  int get total {
    return cart.map((e) => e.total).sum;
  }

  void addToCart(CartItem item) {
    for (final c in cart) {
      if (c.equal(item)) {
        c.quantity++;
        notifyListeners();
        return;
      }
    }
    cart.add(item);
    notifyListeners();
  }

  void addQuantity(CartItem item) {
    addToCart(item);
    notifyListeners();
  }

  void deleteQuantity(CartItem item) {
    cart = cart.where((i) => !i.equal(item)).toList();
    notifyListeners();
  }

  void removeItem(CartItem item) {
    for (var i = 0; i < cart.length; i++) {
      if (cart[i].equal(item)) {
        cart[i].quantity--;
      }
    }
    cart = cart.where((i) => i.quantity > 0).toList();
    notifyListeners();
  }

  List<Specification> getCartListForBill() {
    return cart
        .map((e) => e.toSpecification())
        .expand((e) => e.toList())
        .toList();
  }

  void resetShoppingCart() {
    cart = [];
    notifyListeners();
  }
}
