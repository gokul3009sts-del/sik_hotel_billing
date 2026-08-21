import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../utils/formatters.dart';

class BillItemWidget extends StatelessWidget {
  final Dish dish;
  final int quantity;

  const BillItemWidget({
    super.key,
    required this.dish,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final itemTotal = dish.price * quantity;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(dish.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text('x$quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: Text(Formatters.currency(dish.price), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              Formatters.currency(itemTotal),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
