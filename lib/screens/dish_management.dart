import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/dish.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class DishManagementScreen extends StatefulWidget {
  const DishManagementScreen({super.key});

  @override
  State<DishManagementScreen> createState() => _DishManagementScreenState();
}

class _DishManagementScreenState extends State<DishManagementScreen> {
  final _db = DatabaseHelper.instance;
  List<Dish> _dishes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final dishes = await _db.getActiveDishes();
    setState(() {
      _dishes = dishes;
      _loading = false;
    });
  }

  Future<void> _showDishForm({Dish? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(text: existing != null ? existing.price.toString() : '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Dish' : 'Edit Dish'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Dish name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a dish name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price', prefixText: '\u20B9 '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a price';
                  final parsed = double.tryParse(v);
                  if (parsed == null || parsed <= 0) return 'Enter a valid price';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save Dish'),
          ),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final price = double.parse(priceController.text.trim());
      if (existing == null) {
        await _db.insertDish(name, price);
      } else {
        await _db.updateDish(existing.id!, name, price);
      }
      await _reload();
    }
  }

  Future<void> _confirmDelete(Dish dish) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish'),
        content: Text('Are you sure you want to delete this dish?\n\n"${dish.name}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteDish(dish.id!);
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dish removed from menu. Past bills are unaffected.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Dishes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _dishes.isEmpty
              ? const Center(child: Text('No dishes yet. Tap + to add one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _dishes.length,
                  itemBuilder: (context, index) {
                    final dish = _dishes[index];
                    return Card(
                      child: ListTile(
                        title: Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(Formatters.currency(dish.price)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              onPressed: () => _showDishForm(existing: dish),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.danger),
                              onPressed: () => _confirmDelete(dish),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDishForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Dish'),
      ),
    );
  }
}
