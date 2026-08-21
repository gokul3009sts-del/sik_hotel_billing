import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const DishCard({
    super.key,
    required this.dish,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;
    return Card(
      color: selected ? AppColors.primaryLight.withOpacity(0.12) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.cardBorder, width: selected ? 1.6 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dish.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.currency(dish.price),
              style: const TextStyle(fontSize: 15, color: AppColors.accent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QtyButton(icon: Icons.remove, onTap: quantity > 0 ? onDecrement : null),
                Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _QtyButton(icon: Icons.add, onTap: onIncrement),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
