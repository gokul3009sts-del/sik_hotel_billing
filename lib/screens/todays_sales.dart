import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/bill.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class TodaysSalesScreen extends StatefulWidget {
  const TodaysSalesScreen({super.key});

  @override
  State<TodaysSalesScreen> createState() => _TodaysSalesScreenState();
}

class _TodaysSalesScreenState extends State<TodaysSalesScreen> {
  final _db = DatabaseHelper.instance;
  List<Bill> _bills = [];
  double _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final start = Formatters.startOfDay(now);
    final end = Formatters.endOfDay(now);
    final bills = await _db.getBillsBetween(start, end);
    final total = await _db.getTotalSalesBetween(start, end);
    setState(() {
      _bills = bills;
      _total = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Sales")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(Formatters.dateForDisplay(today), style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "Today's Bills",
                          value: '${_bills.length}',
                          icon: Icons.receipt_long,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: "Today's Total Sales",
                          value: Formatters.currency(_total),
                          icon: Icons.currency_rupee,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Bills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_bills.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('No bills generated today yet.')),
                    )
                  else
                    ..._bills.map((bill) => Card(
                          child: ListTile(
                            title: Text(bill.billNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(bill.billTime),
                            trailing: Text(
                              Formatters.currency(bill.grandTotal),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
