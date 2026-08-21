import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/bill.dart';
import '../services/printer_service.dart';
import '../utils/formatters.dart';

class SalesRecordsScreen extends StatefulWidget {
  const SalesRecordsScreen({super.key});

  @override
  State<SalesRecordsScreen> createState() => _SalesRecordsScreenState();
}

class _SalesRecordsScreenState extends State<SalesRecordsScreen> {
  final _db = DatabaseHelper.instance;
  List<Bill> _bills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final bills = await _db.getAllBills();
    setState(() {
      _bills = bills;
      _loading = false;
    });
  }

  Future<void> _openBill(Bill bill) async {
    final full = await _db.getBillWithItems(bill.id!);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => _BillDetailSheet(bill: full),
    );
  }

  String _formatDate(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Records')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? const Center(child: Text('No bills yet.'))
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _bills.length,
                    itemBuilder: (context, index) {
                      final bill = _bills[index];
                      return Card(
                        child: ListTile(
                          title: Text(bill.billNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${_formatDate(bill.billDate)}  •  ${bill.billTime}'),
                          trailing: Text(
                            Formatters.currency(bill.grandTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          onTap: () => _openBill(bill),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _BillDetailSheet extends StatelessWidget {
  final Bill bill;
  const _BillDetailSheet({required this.bill});

  String _formatDate(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final printerService = PrinterService();
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(bill.billNumber, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${_formatDate(bill.billDate)}  •  ${bill.billTime}', style: const TextStyle(color: Colors.black54)),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: bill.items.length,
                  itemBuilder: (context, index) {
                    final item = bill.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: Text(item.dishName)),
                          Expanded(flex: 2, child: Text('x${item.quantity}', textAlign: TextAlign.center)),
                          Expanded(flex: 3, child: Text(Formatters.currency(item.price), textAlign: TextAlign.right)),
                          Expanded(flex: 3, child: Text(Formatters.currency(item.total), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(Formatters.currency(bill.grandTotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Save/Share'),
                      onPressed: () => printerService.shareBillPdf(bill),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('Print'),
                      onPressed: () => printerService.printBill(bill),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
