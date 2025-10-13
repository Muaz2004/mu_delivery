class CartItem {
  final String foodId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.foodId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;
}
