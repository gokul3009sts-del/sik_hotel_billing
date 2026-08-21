import '../database/database_helper.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../models/dish.dart';

/// Turns the in-memory cart (dish -> quantity) into a permanently saved Bill.
class BillService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Bill> generateBill(Map<Dish, int> cart) async {
    final items = cart.entries.where((e) => e.value > 0).map((e) {
      final dish = e.key;
      final qty = e.value;
      return BillItem(
        dishId: dish.id!,
        dishName: dish.name,
        quantity: qty,
        price: dish.price,
        total: dish.price * qty,
      );
    }).toList();

    if (items.isEmpty) {
      throw Exception('Add at least one item before generating the bill.');
    }

    return await _db.createBillWithItems(items);
  }
}
