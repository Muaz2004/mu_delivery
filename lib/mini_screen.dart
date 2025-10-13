import 'package:flutter/material.dart';
import 'package:mu_delivery/global_cart.dart';

class MiniScreen extends StatelessWidget {
  const MiniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (globalCart.isEmpty) return const SizedBox.shrink(); // hide if empty

    double totalPrice = globalCart.fold(0, (sum, item) => sum + item.subtotal);

    return Container(
      height: 100,
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: globalCart.length,
              itemBuilder: (context, index) {
                final item = globalCart[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        Text('Qty: ${item.quantity}'),
                        Text('\$${item.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
