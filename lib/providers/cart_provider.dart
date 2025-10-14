import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {

  final List<Map<String, dynamic>> _cartItems = [];

  
  List<Map<String, dynamic>> get cartItems => _cartItems;

  
  void addToCart(Map<String, dynamic> food) {
    _cartItems.add(food);
    notifyListeners(); 
  }

  
  void removeFromCart(Map<String, dynamic> food) {
    _cartItems.remove(food);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  
  int get totalItems => _cartItems.length;


  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item['price'] ?? 0;
    }
    return total;
  }
}
